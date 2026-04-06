#!/usr/bin/env bash
# Endurance Plan - Installation Script (Linux/macOS/WSL)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "=== Endurance Plan (续航计划) ==="
echo "Claude Code Token Optimization Toolkit"
echo ""

# 1. Install RTK (Windows only — skip on other platforms)
echo "[1/7] Installing RTK..."
if [[ "$(uname -s)" == *MINGW* ]] || [[ "$(uname -s)" == *MSYS* ]]; then
    mkdir -p "$HOME/.local/bin"
    cp "$SCRIPT_DIR/rtk/rtk.exe" "$HOME/.local/bin/rtk.exe"
    echo "  Installed to ~/.local/bin/rtk.exe"
elif [[ "$(uname -s)" == "Linux" ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    echo "  WSL detected — use RTK via Windows host (rtk.exe in Windows PATH)"
else
    echo "  RTK binary is Windows-only. Skipping. (Other components still work)"
fi

# 2. Install memory backends
echo "[2/7] Installing memory backends..."
PIP_CMD="pip"
command -v pip3 &>/dev/null && PIP_CMD="pip3"

if ! $PIP_CMD show aivectormemory &>/dev/null; then
    $PIP_CMD install aivectormemory --quiet
    echo "  Installed AIVectorMemory"
else
    echo "  AIVectorMemory already installed"
fi
if ! $PIP_CMD show memorygraphMCP &>/dev/null; then
    $PIP_CMD install memorygraphMCP --quiet
    echo "  Installed MemoryGraph"
else
    echo "  MemoryGraph already installed"
fi

# 3. Install skill-loader
echo "[3/7] Installing skill-loader..."
LOADER_DIR="$CLAUDE_DIR/skills/skill-loader"
mkdir -p "$LOADER_DIR"
cp "$SCRIPT_DIR/skill-loader/SKILL.md" "$LOADER_DIR/"
cp "$SCRIPT_DIR/skill-loader/manifest.json" "$LOADER_DIR/"
echo "  Installed to $LOADER_DIR"

# 4. Install agents
echo "[4/7] Installing subagent definitions..."
mkdir -p "$CLAUDE_DIR/agents"
cp "$SCRIPT_DIR/agents/"*.md "$CLAUDE_DIR/agents/"
echo "  Installed research.md, quick-task.md, test-runner.md"

# 5. Install hooks (Python versions — injection-safe)
echo "[5/7] Installing hooks..."
mkdir -p "$CLAUDE_DIR/hooks"
cp "$SCRIPT_DIR/hooks/safety-guard.py" "$CLAUDE_DIR/hooks/"
cp "$SCRIPT_DIR/hooks/filter-test-output.py" "$CLAUDE_DIR/hooks/"
cp "$SCRIPT_DIR/hooks/compress-input.py" "$CLAUDE_DIR/hooks/"
echo "  Installed safety-guard.py, filter-test-output.py, compress-input.py"

# Register hooks in settings.json
SETTINGS="$CLAUDE_DIR/settings.json"
PYTHON_CMD="python"
command -v python3 &>/dev/null && PYTHON_CMD="python3"

if [ -f "$SETTINGS" ]; then
    if ! $PYTHON_CMD -c "import json; d=json.load(open('$SETTINGS')); assert 'hooks' in d" 2>/dev/null; then
        # Merge hooks into existing settings.json
        $PYTHON_CMD -c "
import json
with open('$SETTINGS') as f:
    s = json.load(f)
s['hooks'] = {
    'PreToolUse': [{
        'matcher': 'Bash',
        'hooks': [
            {'type': 'command', 'command': '$PYTHON_CMD ~/.claude/hooks/safety-guard.py'},
            {'type': 'command', 'command': '$PYTHON_CMD ~/.claude/hooks/filter-test-output.py'}
        ]
    }]
}
with open('$SETTINGS', 'w') as f:
    json.dump(s, f, indent=2)
"
        echo "  Registered hooks in settings.json"
    else
        echo "  Hooks already registered in settings.json"
    fi
fi

# 6. Copy templates + register MCP
echo "[6/7] Copying templates..."
if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/templates/CLAUDE.md.template" "$CLAUDE_DIR/CLAUDE.md"
    echo "  Created CLAUDE.md"
else
    echo "  CLAUDE.md already exists, skipping"
fi

# Deploy .claudeignore if not exists
if [ ! -f "$HOME/.claudeignore" ]; then
    cp "$SCRIPT_DIR/templates/claudeignore.template" "$HOME/.claudeignore"
    echo "  Created .claudeignore"
else
    echo "  .claudeignore already exists, skipping"
fi

# Register MCP servers in .claude.json
CLAUDE_JSON="$HOME/.claude.json"
$PYTHON_CMD -c "
import json, os, shutil
path = '$CLAUDE_JSON'
if os.path.exists(path):
    with open(path) as f:
        d = json.load(f)
else:
    d = {'mcpServers': {}}

if 'mcpServers' not in d:
    d['mcpServers'] = {}

changed = False
if 'aivectormemory' not in d['mcpServers']:
    d['mcpServers']['aivectormemory'] = {
        'command': '$PYTHON_CMD',
        'args': ['-m', 'aivectormemory'],
        'type': 'stdio'
    }
    changed = True
if 'memorygraph' not in d['mcpServers']:
    d['mcpServers']['memorygraph'] = {
        'command': 'memorygraph',
        'args': ['--profile', 'extended'],
        'type': 'stdio'
    }
    changed = True

if changed:
    with open(path, 'w') as f:
        json.dump(d, f, indent=2)
    print('  Registered MCP servers in .claude.json')
else:
    print('  MCP servers already registered')
" 2>/dev/null || echo "  Warning: Could not register MCP servers"

# 7. Run skill tiering
echo "[7/7] Running skill tiering..."
if [ -d "$CLAUDE_DIR/skills" ]; then
    $PYTHON_CMD "$SCRIPT_DIR/scripts/tier-skills.py"
else
    echo "  No skills directory found, skipping tiering"
fi

echo ""
echo "=== Installation complete ==="
echo "Restart Claude Code to apply changes."
echo ""
echo "Components installed:"
echo "  - RTK CLI output compression (Windows only)"
echo "  - AIVectorMemory + MemoryGraph (MCP servers registered)"
echo "  - Hooks (safety guard + test filter, registered in settings.json)"
echo "  - Lightweight subagents (research/quick-task/test-runner)"
echo "  - CLAUDE.md with model routing + thinking budget + memory governance"
echo "  - Skill tiering (Tier1 always-on + Tier2 on-demand)"
echo "  - .claudeignore (build artifact exclusion)"
echo ""
echo "Optional: $PIP_CMD install llmlingua  # Enable input compression (~500MB)"
echo "Rollback: $PYTHON_CMD scripts/rollback.py"
