# LLMLingua Input Compression Integration

## Overview

[LLMLingua](https://github.com/microsoft/LLMLingua) (4.5K stars, Microsoft Research) provides
token-level prompt compression that reduces input tokens by 2-5x with minimal semantic loss.

RTK compresses CLI **output** (tool results → context). LLMLingua compresses **input** (file
contents → context). Together they form a bidirectional compression pipeline:

```
File read ──LLMLingua 2-5x──→ Claude context ──RTK 97%──→ CLI output
```

## How It Works

LLMLingua-2 uses a small BERT model (~500MB) to identify which tokens carry the most
information, then removes low-information tokens while preserving structure and meaning.

Example (Python file, 4000 → 1600 tokens):
```
# Before: Full file with comments, whitespace, boilerplate
class UserService:
    """Service for managing user operations including creation,
    retrieval, update, and deletion of user records."""

    def __init__(self, db_connection, cache_layer, logger):
        self.db = db_connection
        self.cache = cache_layer
        self.logger = logger
        self.logger.info("UserService initialized")

# After: Semantically equivalent, ~40% of original tokens
class UserService:
    def __init__(self, db_connection, cache_layer, logger):
        self.db = db_connection
        self.cache = cache_layer
        self.logger = logger
```

## Installation

```bash
pip install llmlingua
```

First run downloads the model (~500MB). No GPU required (CPU inference).

## Integration as PostToolUse Hook

The `compress-input.py` hook intercepts Read tool results and compresses large files
before they enter Claude's context window.

### Configuration

Add to `~/.claude/settings.json`:

```json
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
```

### Behavior

- Files < 4000 chars: passed through unmodified
- Binary/structured files (.json, .csv, .lock): skipped
- Code and docs: compressed to ~40% of original tokens
- Header added: `[Compressed: 4000→1600 tokens (40%)]`

### Tuning

Edit `compress-input.py` to adjust:
- `MIN_SIZE`: Minimum file size to trigger compression (default: 4000 chars)
- `RATE`: Target compression ratio (default: 0.4 = keep 40%)
- `SKIP_EXT`: File extensions to never compress

## Trade-offs

| Pro | Con |
|-----|-----|
| 2-5x input token reduction | ~500MB model download (first run) |
| Preserves code structure | ~1-2s latency per file read |
| No GPU required | May lose some comments/docstrings |
| Works with all languages | Requires Python 3.8+ |

## When to Enable

Enable when:
- Working with large codebases (many files > 200 lines)
- Token budget is very tight (third-party API relay)
- Reading lots of documentation files

Disable when:
- Exact file content matters (reviewing diffs, debugging)
- Files are already small (< 100 lines)
- Latency is critical (fast iteration loops)
