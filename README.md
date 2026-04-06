# Endurance Plan / 续航计划

**Claude Code Token Optimization Toolkit** - Make every token count.

A comprehensive token optimization system for [Claude Code](https://code.claude.com/) that reduces token consumption by **60-90%** through CLI output compression, skill tiering, intelligent model routing, and thinking budget control.

## Problem

Claude Code consumes ~$6-12/day per developer. Major token sinks:
- **CLI output**: Full build/test output floods the context window
- **Skill descriptions**: 150+ skills inject ~10K tokens into every system prompt
- **Model overkill**: Opus for everything, including simple file searches
- **Thinking overhead**: Maximum thinking budget on trivial tasks

## Solution

| Component | What It Does | Token Savings |
|-----------|-------------|---------------|
| **RTK** | CLI output compression (smart filters per command) | 60-90% per command |
| **Skill Tiering** | 23 always-on + 158 on-demand via skill-loader | ~8K tokens/turn |
| **Model Routing** | Sonnet/Haiku subagents for lightweight tasks | ~60% cost on delegated tasks |
| **Thinking Budget** | `effortLevel: high` default, max on demand | Thousands of output tokens/request |
| **.claudeignore** | Exclude build artifacts, lock files, models | Prevents context pollution |
| **Memory Architecture** | Three-tier: index -> topic files -> semantic search | Minimal always-on injection |

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
# Instead of: npm test (raw output floods context)
rtk npm test          # Compressed: only failures + summary

# Error-only mode
rtk err cargo build   # Show only errors

# Smart summary
rtk summary git log   # AI-compressed summary

# Check savings
rtk gain              # Show compression statistics
```

**Average compression: 97%** on tested workloads (121K tokens -> ~3.6K tokens).

### Skill Tiering

Split skills into always-on (Tier 1) and on-demand (Tier 2):

- **Tier 1** (23 skills): Core coding, memory, search, communication, tools
- **Tier 2** (158 skills): Loaded by `skill-loader` when triggered by keywords

The `skill-loader` skill contains a compact index (~2K tokens) of all disabled skills. When a user request matches a Tier 2 skill, it reads the skill's `SKILL.md` and follows its instructions.

```
# Customize Tier 1 list in scripts/tier-skills.py
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

CLAUDE.md includes routing guidance so Claude delegates appropriately.

### Thinking Budget Control

Default `effortLevel: high` balances quality and cost. Use `/effort` to adjust per-task:

| Level | When to Use |
|-------|-------------|
| `max` | Complex architecture, multi-step debugging |
| `high` | Daily coding (default) |
| `low` | Simple queries, status checks |

### .claudeignore Template

Comprehensive exclusion list for:
- Package managers: `node_modules/`, `vendor/`, `.pnpm/`
- Build artifacts: `dist/`, `build/`, `.next/`
- Lock files: `package-lock.json`, `pnpm-lock.yaml`, etc.
- AI/ML models: `*.onnx`, `*.safetensors`, `*.gguf`
- Caches: `__pycache__/`, `.turbo/`, `.cache/`

### Memory Architecture

Three-tier memory system:

1. **MEMORY.md** (always loaded): Compact index, <200 lines, links to topic files
2. **Topic files** (on-demand): `user-profile.md`, `feedback.md`, `decisions.md`, `patterns.md`
3. **Semantic search** (MCP): mnemex or similar vector search for long-term recall

## Architecture

```
~/.claude/
├── CLAUDE.md                    # RTK instructions + model routing + thinking budget
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
```

## Token Savings Summary

| Metric | Before | After |
|--------|--------|-------|
| CLI output tokens | 100% raw | **3-10%** (RTK compressed) |
| System prompt skills | ~10K tokens/turn | **~2K tokens/turn** |
| Model cost per delegated task | 100% (Opus) | **~40%** (Sonnet/Haiku) |
| Thinking tokens per simple task | Maximum | **~50%** (high vs max) |
| Memory context injection | Variable | **<200 lines** fixed |

## Rollback

Every operation is reversible:

```bash
# Restore all skill manifests from backup
python scripts/rollback.py

# Restore from specific backup
python scripts/rollback.py ~/.claude/skills-archive/pre-tiering-20260406/

# Remove RTK (just delete the binary)
rm ~/.local/bin/rtk

# Revert settings: change effortLevel back to "max" in settings.json
```

## Requirements

- [Claude Code](https://code.claude.com/) CLI installed
- Python 3.8+ (for tiering scripts)
- Windows 10/11, macOS, or Linux

## License

MIT
