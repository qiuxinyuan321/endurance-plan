# Endurance Plan - Installation Script (Windows)
# PowerShell

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = "$env:USERPROFILE\.claude"

Write-Host "=== Endurance Plan (续航计划) ===" -ForegroundColor Cyan
Write-Host "Claude Code Token Optimization Toolkit"
Write-Host ""

# 1. Install RTK
Write-Host "[1/6] Installing RTK..." -ForegroundColor Yellow
$RtkDir = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Force -Path $RtkDir | Out-Null
Copy-Item "$ScriptDir\rtk\rtk.exe" "$RtkDir\rtk.exe" -Force
Write-Host "  Installed to $RtkDir\rtk.exe"

# Ensure PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$RtkDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$RtkDir", "User")
    Write-Host "  Added $RtkDir to PATH"
}

# 2. Install AIVectorMemory + MemoryGraph
Write-Host "[2/6] Installing memory backends..." -ForegroundColor Yellow
$avmCheck = pip show aivectormemory 2>$null
if (-not $avmCheck) {
    pip install aivectormemory --quiet
    Write-Host "  Installed AIVectorMemory"
} else {
    Write-Host "  AIVectorMemory already installed"
}
$mgCheck = pip show memorygraphMCP 2>$null
if (-not $mgCheck) {
    pip install memorygraphMCP --quiet
    Write-Host "  Installed MemoryGraph"
} else {
    Write-Host "  MemoryGraph already installed"
}

# 3. Install skill-loader
Write-Host "[3/6] Installing skill-loader..." -ForegroundColor Yellow
$LoaderDir = "$ClaudeDir\skills\skill-loader"
New-Item -ItemType Directory -Force -Path $LoaderDir | Out-Null
Copy-Item "$ScriptDir\skill-loader\SKILL.md" "$LoaderDir\" -Force
Copy-Item "$ScriptDir\skill-loader\manifest.json" "$LoaderDir\" -Force
Write-Host "  Installed to $LoaderDir"

# 4. Install agents
Write-Host "[4/7] Installing subagent definitions..." -ForegroundColor Yellow
$AgentsDir = "$ClaudeDir\agents"
New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null
Get-ChildItem "$ScriptDir\agents\*.md" | Copy-Item -Destination $AgentsDir -Force
Write-Host "  Installed research.md, quick-task.md, test-runner.md"

# 5. Install hooks
Write-Host "[5/7] Installing hooks..." -ForegroundColor Yellow
$HooksDir = "$ClaudeDir\hooks"
New-Item -ItemType Directory -Force -Path $HooksDir | Out-Null
Copy-Item "$ScriptDir\hooks\*" "$HooksDir\" -Force
Write-Host "  Installed safety-guard.sh, filter-test-output.sh, compress-input.py"

# 6. Copy templates
Write-Host "[6/7] Copying templates..." -ForegroundColor Yellow
if (-not (Test-Path "$ClaudeDir\CLAUDE.md")) {
    Copy-Item "$ScriptDir\templates\CLAUDE.md.template" "$ClaudeDir\CLAUDE.md"
    Write-Host "  Created CLAUDE.md"
} else {
    Write-Host "  CLAUDE.md already exists, skipping"
}

# 7. Run skill tiering
Write-Host "[7/7] Running skill tiering..." -ForegroundColor Yellow
if (Test-Path "$ClaudeDir\skills") {
    python "$ScriptDir\scripts\tier-skills.py"
} else {
    Write-Host "  No skills directory found, skipping tiering"
}

Write-Host ""
Write-Host "=== Installation complete ===" -ForegroundColor Green
Write-Host "Restart Claude Code to apply changes."
Write-Host ""
Write-Host "Components installed:"
Write-Host "  - RTK CLI output compression"
Write-Host "  - AIVectorMemory (vector memory + issue tracking + task management)"
Write-Host "  - MemoryGraph (graph memory + causal reasoning + relationship tracking)"
Write-Host "  - Skill Loader (on-demand skill routing)"
Write-Host "  - Hooks (safety guard + test filter + optional LLMLingua compression)"
Write-Host "  - Lightweight subagents (research/quick-task/test-runner)"
Write-Host "  - CLAUDE.md with model routing + thinking budget + memory governance"
Write-Host "  - Skill tiering (Tier1 always-on + Tier2 on-demand)"
Write-Host ""
Write-Host "Next: Add AIVectorMemory MCP config to ~/.claude.json (see templates/mcp-servers.json.template)"
Write-Host ""
Write-Host "Rollback: python scripts\rollback.py"
