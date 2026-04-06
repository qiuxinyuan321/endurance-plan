# Endurance Plan / 续航计划

**Claude Code Token Optimization + Intelligent Memory Toolkit**

A comprehensive optimization system for [Claude Code](https://code.claude.com/) that reduces token consumption by **60-90%** and provides five-tier intelligent memory through CLI compression, skill tiering, model routing, thinking budget control, and multi-backend MCP memory.

## Problem

Claude Code consumes ~$6-12/day per developer. Major cost sinks:
- **CLI output**: Full build/test output floods the context window
- **Skill descriptions**: 150+ skills inject ~10K tokens into every system prompt
- **Model overkill**: Opus for everything, including simple file searches
- **Thinking overhead**: Maximum thinking budget on trivial tasks
- **Memory fragmentation**: No unified strategy for cross-session knowledge persistence

## Solution

### Token Optimization

| Component | What It Does | Savings |
|-----------|-------------|---------|
| **RTK** | CLI output compression (smart filters per command) | 60-90% per command |
| **Skill Tiering** | 23 always-on + 158 on-demand via skill-loader | ~8K tokens/turn |
| **Model Routing** | Sonnet/Haiku subagents for lightweight tasks | ~60% cost on delegated tasks |
| **Thinking Budget** | `effortLevel: high` default, max on demand | Thousands of output tokens/request |
| **.claudeignore** | Exclude build artifacts, lock files, models | Prevents context pollution |

### Five-Tier Memory

| Tier | Backend | Best For |
|------|---------|----------|
| **Core** | MEMORY.md (always loaded) | Quick index, <200 lines |
| **Recall** | Topic markdown files | Structured notes, on-demand Read |
| **Vector** | [AIVectorMemory](https://github.com/Edlineas/aivectormemory) MCP | Semantic search + issue tracking + task management |
| **Graph** | [MemoryGraph](https://github.com/memory-graph/memory-graph) MCP | Causal chains + relationship tracking + multi-hop reasoning |
| **Code Intel** | [mnemex](https://github.com/mnemex/mnemex) MCP | AST index + code definitions + references |

## Quick Start

### Windows (PowerShell)
```powershell
git clone https://github.com/qiuxinyuan321/endurance-plan.git
cd endurance-plan
.\install.ps1
```

### Linux/macOS/WSL
```bash
git clone https://github.com/qiuxinyuan321/endurance-plan.git
cd endurance-plan
chmod +x install.sh && ./install.sh
```

Then restart Claude Code.

## Components

### RTK - CLI Output Compression

A binary tool that wraps CLI commands and compresses their output before it enters the context window.

```bash
rtk npm test          # Compressed: only failures + summary
rtk err cargo build   # Show only errors
rtk summary git log   # AI-compressed summary
rtk gain              # Show compression statistics
```

**Average compression: 97%** on tested workloads (121K tokens -> ~3.6K tokens).

### Skill Tiering

Split skills into always-on (Tier 1) and on-demand (Tier 2):

- **Tier 1** (23 skills): Core coding, memory, search, communication, tools
- **Tier 2** (158 skills): Loaded by `skill-loader` when triggered by keywords

```bash
python scripts/tier-skills.py              # Apply tiering
python scripts/tier-skills.py --dry-run    # Preview changes
python scripts/rollback.py                 # Restore from backup
```

### Model Routing

Three subagent definitions optimized for cost:

| Agent | Model | Use Case |
|-------|-------|----------|
| `research` | Sonnet | Codebase exploration, file search, doc lookup |
| `quick-task` | Sonnet | Simple code changes, formatting |
| `test-runner` | Haiku | Run tests, report pass/fail |

### Thinking Budget Control

Default `effortLevel: high` balances quality and cost:

| Level | When to Use |
|-------|-------------|
| `max` | Complex architecture, multi-step debugging |
| `high` | Daily coding (default) |
| `low` | Simple queries, status checks |

### Memory System

#### AIVectorMemory (Vector Memory)
- **Semantic search**: Find "database timeout" when searching "MySQL connection pool pitfall"
- **Issue tracking**: Full lifecycle from discovery to resolution
- **Task management**: Multi-step requirement decomposition
- **Smart dedup**: Auto-merges memories with >0.95 similarity
- **Web dashboard**: 3D vector visualization at `localhost:9080`

#### MemoryGraph (Graph Memory)
- **Relationship tracking**: 7 types (causal, solution, context, learning, similarity, workflow, quality)
- **Multi-hop reasoning**: Trace causal chains across decisions
- **Solution evolution**: Track how approaches change over time (SUPERSEDED_BY)
- **Extended mode**: 12 tools for advanced querying

#### Memory Routing Guide

| Need | Tool |
|------|------|
| Store cross-session knowledge | AIVectorMemory `remember` |
| Semantic similarity search | AIVectorMemory `recall` |
| Track bugs/issues | AIVectorMemory `track` |
| Decompose tasks | AIVectorMemory `task` |
| Record causal relationships | MemoryGraph `create_entities` + `create_relations` |
| Multi-hop reasoning | MemoryGraph `search_nodes` + `open_nodes` |
| Code definitions/references | mnemex `define` / `references` / `search` |

### .claudeignore Template

Comprehensive exclusion list: node_modules, build artifacts, lock files, AI/ML models, caches, IDE configs.

## Architecture

```
~/.claude/
├── CLAUDE.md                    # RTK + model routing + thinking budget + memory governance
├── settings.json                # effortLevel: high, model config
├── agents/
│   ├── research.md              # Sonnet - codebase exploration
│   ├── quick-task.md            # Sonnet - simple changes
│   └── test-runner.md           # Haiku - test execution
├── skills/
│   └── skill-loader/
│       ├── SKILL.md             # On-demand skill index + routing
│       └── manifest.json        # enabled: true, priority: 100
└── skills-archive/
    └── pre-tiering-YYYYMMDD/    # Backup of original manifests

MCP Servers (configured in ~/.claude.json):
├── aivectormemory               # Vector memory + issue/task
├── memorygraph                  # Graph memory + relationships
├── mnemex                       # Code intelligence
└── github                       # GitHub API
```

## Token Savings Summary

| Metric | Before | After |
|--------|--------|-------|
| CLI output tokens | 100% raw | **3-10%** (RTK compressed) |
| System prompt skills | ~10K tokens/turn | **~2K tokens/turn** |
| Model cost per delegated task | 100% (Opus) | **~40%** (Sonnet/Haiku) |
| Thinking tokens per simple task | Maximum | **~50%** (high vs max) |
| Memory context injection | Variable | **<200 lines** fixed |
| Cross-session knowledge | Lost | **Persistent** (vector + graph) |

## Rollback

Every operation is reversible:

```bash
python scripts/rollback.py                                    # Restore skill manifests
python scripts/rollback.py ~/.claude/skills-archive/pre-tiering-20260406/  # From specific backup
rm ~/.local/bin/rtk                                           # Remove RTK
pip uninstall aivectormemory memorygraphMCP                   # Remove memory backends
```

## Credits

This toolkit integrates and builds upon:
- [AIVectorMemory](https://github.com/Edlineas/aivectormemory) by Edlineas - Vector memory + issue tracking
- [MemoryGraph](https://github.com/memory-graph/memory-graph) by memory-graph - Graph-based relationship memory

## Requirements

- [Claude Code](https://code.claude.com/) CLI installed
- Python 3.10+ (for memory backends and tiering scripts)
- Windows 10/11, macOS, or Linux

## License

MIT
