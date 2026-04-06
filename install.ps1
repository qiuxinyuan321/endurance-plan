# Endurance Plan - Installation Script (Windows)
# PowerShell

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = "$env:USERPROFILE\.claude"

Write-Host "=== Endurance Plan (续航计划) ===" -ForegroundColor Cyan
Write-Host "Claude Code Token Optimization Toolkit"
Write-Host ""

# 1. Install RTK
Write-Host "[1/5] Installing RTK..." -ForegroundColor Yellow
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

# 2. Install skill-loader
Write-Host "[2/5] Installing skill-loader..." -ForegroundColor Yellow
$LoaderDir = "$ClaudeDir\skills\skill-loader"
New-Item -ItemType Directory -Force -Path $LoaderDir | Out-Null
Copy-Item "$ScriptDir\skill-loader\SKILL.md" "$LoaderDir\" -Force
Copy-Item "$ScriptDir\skill-loader\manifest.json" "$LoaderDir\" -Force
Write-Host "  Installed to $LoaderDir"

# 3. Install agents
Write-Host "[3/5] Installing subagent definitions..." -ForegroundColor Yellow
$AgentsDir = "$ClaudeDir\agents"
New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null
Get-ChildItem "$ScriptDir\agents\*.md" | Copy-Item -Destination $AgentsDir -Force
Write-Host "  Installed research.md, quick-task.md, test-runner.md"

# 4. Copy templates
Write-Host "[4/5] Copying templates..." -ForegroundColor Yellow
if (-not (Test-Path "$ClaudeDir\CLAUDE.md")) {
    Copy-Item "$ScriptDir\templates\CLAUDE.md.template" "$ClaudeDir\CLAUDE.md"
    Write-Host "  Created CLAUDE.md"
} else {
    Write-Host "  CLAUDE.md already exists, skipping"
}

# 5. Run skill tiering
Write-Host "[5/5] Running skill tiering..." -ForegroundColor Yellow
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
Write-Host "  - Skill Loader (on-demand skill routing)"
Write-Host "  - Lightweight subagents (research/quick-task/test-runner)"
Write-Host "  - CLAUDE.md with model routing + thinking budget guidance"
Write-Host "  - Skill tiering (Tier1 always-on + Tier2 on-demand)"
Write-Host ""
Write-Host "Rollback: python scripts\rollback.py"
