# MemoryGraph Integration Guide

## Overview

MemoryGraph (203 stars) provides graph-based memory with intelligent relationship tracking.
Unlike flat vector memory, it captures causal chains, solution evolution, and multi-hop reasoning.

## Why Graph Memory Matters

Vector memory (AIVectorMemory) treats each memory as an isolated point in embedding space.
Graph memory connects them with typed relationships:

```
Flat (vector):
  [1] "retry logic fixed timeout issue"
  [2] "memory leak found in connection pool"
  [3] "connection pooling solved the leak"

Graph (memorygraph):
  [timeout_fix] --CAUSES--> [memory_leak] --SOLVED_BY--> [connection_pooling]
```

When you ask "what caused the memory leak?", the graph traces the causal chain automatically.

## Architecture: Five-Tier Memory

```
Tier 1: Core (MEMORY.md)              → Always injected, <200 lines index
Tier 2: Recall (topic files)           → On-demand Read, structured markdown
Tier 3: Vector (AIVectorMemory)        → Semantic similarity search + issue/task
Tier 4: Graph (MemoryGraph)            → Relationship tracking + causal reasoning
Tier 5: Code Intel (mnemex)            → AST index, definitions, references
```

### Routing Guide

| Need | Use |
|------|-----|
| "What was that database fix?" | AIVectorMemory `recall` (semantic similarity) |
| "Why did we change the auth flow?" | MemoryGraph `search_nodes` (causal chain) |
| "What bugs came from the Redis migration?" | MemoryGraph `open_nodes` (multi-hop) |
| "Where is UserService defined?" | mnemex `define` (code intelligence) |
| "Track this new bug" | AIVectorMemory `track` (issue lifecycle) |

## Installation

```bash
pip install memorygraphMCP

# Optional backends:
pip install "memorygraphMCP[neo4j]"       # For production graph DB
pip install "memorygraphMCP[falkordblite]" # Lightweight alternative
```

## MCP Configuration

Add to `~/.claude.json` under `mcpServers`:

```json
{
  "memorygraph": {
    "command": "memorygraph",
    "args": ["--profile", "extended"],
    "type": "stdio"
  }
}
```

### Modes

| Mode | Tools | Use Case |
|------|-------|----------|
| Core (default) | 9 tools | Basic memory CRUD |
| Extended | 12 tools | Advanced querying, relationship search |

## Relationship Types

MemoryGraph tracks 7 relationship categories:

| Type | Example |
|------|---------|
| `causal` | Bug A caused Bug B |
| `solution` | Fix X resolved Issue Y |
| `context` | Module A depends on Config B |
| `learning` | Pattern P emerged from Experience E |
| `similarity` | Approach A is similar to Approach B |
| `workflow` | Step 1 precedes Step 2 |
| `quality` | Metric M measures Component C |

## Coexistence Strategy

Three memory MCP servers running simultaneously:
- **AIVectorMemory**: Best for similarity search + issue/task workflows
- **MemoryGraph**: Best for relationship tracking + causal reasoning
- **mnemex**: Best for code-level intelligence (AST, type system)

No conflicts - each uses its own database and serves distinct query patterns.
