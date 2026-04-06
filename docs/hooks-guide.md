# Hooks System Guide

## Overview

Claude Code hooks run shell commands at specific lifecycle points. They're deterministic
(unlike CLAUDE.md instructions) and guarantee the action happens.

Endurance Plan includes three hook scripts for token optimization and safety.

## Available Hooks

### 1. Safety Guard (`safety-guard.sh`)

Blocks dangerous commands before execution. Inspired by OpenHands event-stream architecture.

| Action | Patterns |
|--------|----------|
| **Block** | `rm -rf /`, fork bomb, `dd if=/dev/zero`, `curl \| bash` |
| **Warn (ask)** | `git push --force`, `git reset --hard`, `DROP TABLE`, `npm publish` |
| **Allow** | Everything else |

### 2. Test Output Filter (`filter-test-output.sh`)

Intercepts test runner commands and filters output to failures + summary only.
Catches: `npm test`, `pytest`, `go test`, `cargo test`, `vitest`, `jest`, etc.

Typical savings: 500+ line test output → 10-50 lines (90%+ reduction).

### 3. Input Compression (`compress-input.py`)

Optional LLMLingua-2 hook that compresses large file reads. See [llmlingua-compression.md](llmlingua-compression.md).

## Installation

Copy hooks to `~/.claude/hooks/`:

```bash
mkdir -p ~/.claude/hooks
cp hooks/*.sh hooks/*.py ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

Merge `templates/hooks.json.template` into your `~/.claude/settings.json`.

## Hook Architecture

```
User Request
    │
    ▼
PreToolUse ──→ safety-guard.sh ──→ Block/Warn/Allow
    │              │
    │              ▼
    │         filter-test-output.sh ──→ Wrap test commands
    │
    ▼
Tool Executes (Read/Bash/Edit/etc.)
    │
    ▼
PostToolUse ──→ compress-input.py ──→ Compress large Read results
    │
    ▼
Result enters Claude's context (compressed)
```

## Custom Hooks

Create your own hooks following the pattern:

```bash
#!/usr/bin/env bash
# Read JSON from stdin
input=$(cat)
cmd=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))")

# Your logic here...

# Options:
# Pass through:  echo "{}"
# Block:         echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","reason":"..."}}'
# Allow:         echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
# Modify input:  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","updatedInput":{"command":"..."}}}'
```

## Sources

- Safety patterns: [OpenHands](https://github.com/All-Hands-AI/OpenHands) event-stream architecture
- Test filtering: [Anthropic Claude Code docs](https://code.claude.com/docs/en/costs#offload-processing-to-hooks-and-skills)
- Community patterns: [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
