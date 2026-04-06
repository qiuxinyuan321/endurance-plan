# AIVectorMemory Integration Guide

## Overview

AIVectorMemory provides persistent vector memory + issue tracking + task management via MCP.
It complements mnemex (code intelligence) and the file-based memory architecture.

## Architecture: Four-Tier Memory

```
Tier 1: Core (MEMORY.md)           → Always injected, <200 lines index
Tier 2: Recall (topic files)        → On-demand Read, structured markdown
Tier 3: Vector (AIVectorMemory)     → Semantic search, cross-session persistence
Tier 4: Code Intel (mnemex)         → AST index, definitions, references, call graph
```

### When to Use Which

| Need | Tool | Example |
|------|------|---------|
| Quick project notes | MEMORY.md + topic files | User preferences, architecture decisions |
| Cross-session knowledge | AIVectorMemory `remember` | "Database timeout fix: increase pool_size to 20" |
| Find past solutions | AIVectorMemory `recall` | "How did we fix the auth token issue?" |
| Track bugs | AIVectorMemory `track` | "Login fails after session timeout" |
| Manage tasks | AIVectorMemory `task` | Decompose "add OAuth" into subtasks |
| Find code definitions | mnemex `define` | "Where is UserService defined?" |
| Find code references | mnemex `references` | "Who calls authenticate()?" |

## Installation

```bash
pip install aivectormemory
```

## MCP Configuration

Add to `~/.claude.json` under `mcpServers`:

```json
{
  "aivectormemory": {
    "command": "python",
    "args": ["-m", "aivectormemory"],
    "type": "stdio"
  }
}
```

For project-specific data directory:
```json
{
  "aivectormemory": {
    "command": "python",
    "args": ["-m", "aivectormemory", "--project-dir", "/path/to/project"],
    "type": "stdio"
  }
}
```

## Available MCP Tools

| Tool | Purpose |
|------|---------|
| `remember` | Store knowledge with tags; auto-deduplicates at >0.95 similarity |
| `recall` | Semantic search across stored memories |
| `forget` | Delete memories by ID or batch |
| `status` | Cross-session state: blocks, current task, progress |
| `track` | Issue lifecycle: create → update → archive |
| `task` | Task decomposition with subtasks |
| `readme` | Auto-generate documentation |
| `auto_save` | Extract and store user preferences |

## Web Dashboard (Optional)

```bash
python -m aivectormemory web --port 9080
# Open http://localhost:9080 (default: admin/admin123)
```

## Coexistence with mnemex

Both MCP servers run simultaneously:
- **mnemex**: Code-level intelligence (AST, embeddings via Ollama)
- **AIVectorMemory**: Knowledge-level memory (vector search via ONNX)

No conflicts - they use separate databases and serve different purposes.
