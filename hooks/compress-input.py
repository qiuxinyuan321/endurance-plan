#!/usr/bin/env python3
"""
Endurance Plan - Input Compression Hook (PostToolUse on Read)

Compresses large file contents after Read, before they enter Claude's context.
Uses LLMLingua-2 for token-level compression with minimal semantic loss.

Install: pip install llmlingua
Model: microsoft/llmlingua-2-bert-base-multilingual-cased-meetingbank (~500MB, no GPU needed)

Hook config in settings.json:
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Read",
      "hooks": [{
        "type": "command",
        "command": "python ~/.claude/hooks/compress-input.py"
      }]
    }]
  }
}
"""
import json
import sys
import os

# Only compress outputs larger than this (characters)
MIN_SIZE = 4000
# Target: keep ~40% of tokens (balance between savings and quality)
RATE = 0.4
# Skip these extensions (binary/structured data)
SKIP_EXT = {'.json', '.lock', '.csv', '.svg', '.png', '.jpg', '.gif', '.ico', '.wasm'}

_compressor = None

def get_compressor():
    global _compressor
    if _compressor is None:
        try:
            from llmlingua import PromptCompressor
            _compressor = PromptCompressor(
                model_name="microsoft/llmlingua-2-bert-base-multilingual-cased-meetingbank",
                use_llmlingua2=True,
            )
        except Exception:
            _compressor = False  # Mark as failed
    return _compressor if _compressor is not False else None


def main():
    try:
        data = json.loads(sys.stdin.read())
    except Exception:
        print("{}")
        return

    tool_input = data.get("tool_input", {})
    tool_result = data.get("tool_result", "")
    file_path = tool_input.get("file_path", "")

    # Skip small files, binary files, or missing results
    if not tool_result or len(tool_result) < MIN_SIZE:
        print("{}")
        return

    ext = os.path.splitext(file_path)[1].lower()
    if ext in SKIP_EXT:
        print("{}")
        return

    compressor = get_compressor()
    if not compressor:
        print("{}")
        return

    try:
        result = compressor.compress_prompt(
            [tool_result],
            rate=RATE,
            force_tokens=['\n', '.', '!', '?', ',', ':', ';',
                         '(', ')', '{', '}', '[', ']',
                         'def ', 'class ', 'function ', 'import ', 'from ',
                         'return ', 'if ', 'else ', 'for ', 'while '],
        )
        compressed = result.get("compressed_prompt", "")
        if compressed and len(compressed) < len(tool_result) * 0.9:
            original_tokens = result.get("origin_tokens", 0)
            compressed_tokens = result.get("compressed_tokens", 0)
            header = f"[Compressed: {original_tokens}→{compressed_tokens} tokens ({compressed_tokens*100//max(original_tokens,1)}%)]\n"
            output = json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PostToolUse",
                    "updatedResult": header + compressed
                }
            })
            print(output)
            return
    except Exception:
        pass

    print("{}")


if __name__ == "__main__":
    main()
