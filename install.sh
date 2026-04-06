#!/usr/bin/env bash
# Endurance Plan - Installation Script (Linux/macOS/WSL)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "=== Endurance Plan (续航计划) ==="
echo "Claude Code Token Optimization Toolkit"
echo ""

# 1. Install RTK
echo "[1/5] Installing RTK..."
mkdir -p "$HOME/.local/bin"
if [[ "$(uname -s)" == "Linux" ]]; then
    # For Linux/WSL, user needs to build from source or download correct binary
    echo "  RTK Windows binary detected. For Linux, build from source or download the Linux release."
    echo "  Skipping RTK installation."
else
    cp "$SCRIPT_DIR/rtk/rtk.exe" "$HOME/.local/bin/rtk"
    echo "  Installed to ~/.local/bin/rtk"
fi

# 2. Install skill-loader
echo "[2/5] Installing skill-loader..."
LOADER_DIR="$CLAUDE_DIR/skills/skill-loader"
mkdir -p "$LOADER_DIR"
cp "$SCRIPT_DIR/skill-loader/SKILL.md" "$LOADER_DIR/"
cp "$SCRIPT_DIR/skill-loader/manifest.json" "$LOADER_DIR/"
echo "  Installed to $LOADER_DIR"

# 3. Install agents
echo "[3/5] Installing subagent definitions..."
mkdir -p "$CLAUDE_DIR/agents"
cp "$SCRIPT_DIR/agents/"*.md "$CLAUDE_DIR/agents/"
echo "  Installed research.md, quick-task.md, test-runner.md"

# 4. Copy templates (don't overwrite existing)
echo "[4/5] Copying templates..."
if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/templates/CLAUDE.md.template" "$CLAUDE_DIR/CLAUDE.md"
    echo "  Created CLAUDE.md"
else
    echo "  CLAUDE.md already exists, skipping (template at templates/CLAUDE.md.template)"
fi

# 5. Run skill tiering
echo "[5/5] Running skill tiering..."
if [ -d "$CLAUDE_DIR/skills" ]; then
    python3 "$SCRIPT_DIR/scripts/tier-skills.py"
else
    echo "  No skills directory found, skipping tiering"
fi

echo ""
echo "=== Installation complete ==="
echo "Restart Claude Code to apply changes."
echo ""
echo "Components installed:"
echo "  - RTK CLI output compression"
echo "  - Skill Loader (on-demand skill routing)"
echo "  - Lightweight subagents (research/quick-task/test-runner)"
echo "  - CLAUDE.md with model routing + thinking budget guidance"
echo "  - Skill tiering (Tier1 always-on + Tier2 on-demand)"
echo ""
echo "Rollback: python scripts/rollback.py"
