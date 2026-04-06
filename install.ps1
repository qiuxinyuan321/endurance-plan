# Endurance Plan - Installation Script (Windows)
# PowerShell

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = "$env:USERPROFILE\.claude"

Write-Host "=== Endurance Plan (续航计划) ===" -ForegroundColor Cyan
Write-Host "Claude Code Token Optimization Toolkit"
Write-Host ""

# 1. Install RTK
Write-Host "[1/7] Installing RTK..." -ForegroundColor Yellow
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
Write-Host "[2/7] Installing memory backends..." -ForegroundColor Yellow
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
Write-Host "[3/7] Installing skill-loader..." -ForegroundColor Yellow
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

# 5. Install hooks (Python versions — injection-safe)
Write-Host "[5/7] Installing hooks..." -ForegroundColor Yellow
$HooksDir = "$ClaudeDir\hooks"
New-Item -ItemType Directory -Force -Path $HooksDir | Out-Null
Copy-Item "$ScriptDir\hooks\safety-guard.py" "$HooksDir\" -Force
Copy-Item "$ScriptDir\hooks\filter-test-output.py" "$HooksDir\" -Force
Copy-Item "$ScriptDir\hooks\compress-input.py" "$HooksDir\" -Force
Write-Host "  Installed safety-guard.py, filter-test-output.py, compress-input.py"

# Register hooks in settings.json
$SettingsPath = "$ClaudeDir\settings.json"
if (Test-Path $SettingsPath) {
    $settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json
} else {
    $settings = @{} | ConvertTo-Json | ConvertFrom-Json
}
if (-not $settings.hooks) {
    $hooksConfig = @{
        PreToolUse = @(
            @{
                matcher = "Bash"
                hooks = @(
                    @{ type = "command"; command = "python ~/.claude/hooks/safety-guard.py" },
                    @{ type = "command"; command = "python ~/.claude/hooks/filter-test-output.py" }
                )
            }
        )
    }
    $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue $hooksConfig -Force
    $settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsPath -Encoding UTF8
    Write-Host "  Registered hooks in settings.json"
} else {
    Write-Host "  Hooks already registered in settings.json"
}

# 6. Copy templates (don't overwrite existing)
Write-Host "[6/7] Copying templates..." -ForegroundColor Yellow
if (-not (Test-Path "$ClaudeDir\CLAUDE.md")) {
    Copy-Item "$ScriptDir\templates\CLAUDE.md.template" "$ClaudeDir\CLAUDE.md"
    Write-Host "  Created CLAUDE.md"
} else {
    Write-Host "  CLAUDE.md already exists, skipping"
}

# Deploy .claudeignore if not exists
if (-not (Test-Path "$env:USERPROFILE\.claudeignore")) {
    Copy-Item "$ScriptDir\templates\claudeignore.template" "$env:USERPROFILE\.claudeignore"
    Write-Host "  Created .claudeignore"
} else {
    Write-Host "  .claudeignore already exists, skipping"
}

# Register MCP servers in .claude.json
$ClaudeJsonPath = "$env:USERPROFILE\.claude.json"
if (Test-Path $ClaudeJsonPath) {
    $claudeJson = Get-Content $ClaudeJsonPath -Raw | ConvertFrom-Json
} else {
    $claudeJson = @{mcpServers = @{}} | ConvertTo-Json -Depth 5 | ConvertFrom-Json
}
if (-not $claudeJson.mcpServers.aivectormemory) {
    $pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source
    if ($pythonPath) {
        $claudeJson.mcpServers | Add-Member -NotePropertyName "aivectormemory" -NotePropertyValue @{
            command = $pythonPath
            args = @("-m", "aivectormemory")
            type = "stdio"
        } -Force
        $claudeJson.mcpServers | Add-Member -NotePropertyName "memorygraph" -NotePropertyValue @{
            command = "memorygraph"
            args = @("--profile", "extended")
            type = "stdio"
        } -Force
        $claudeJson | ConvertTo-Json -Depth 10 | Set-Content $ClaudeJsonPath -Encoding UTF8
        Write-Host "  Registered MCP servers in .claude.json"
    } else {
        Write-Host "  Python not found, skipping MCP registration"
    }
} else {
    Write-Host "  MCP servers already registered"
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
Write-Host "  - AIVectorMemory + MemoryGraph (MCP servers registered)"
Write-Host "  - Hooks (safety guard + test filter, registered in settings.json)"
Write-Host "  - Lightweight subagents (research/quick-task/test-runner)"
Write-Host "  - CLAUDE.md with model routing + thinking budget + memory governance"
Write-Host "  - Skill tiering (Tier1 always-on + Tier2 on-demand)"
Write-Host "  - .claudeignore (build artifact exclusion)"
Write-Host ""
Write-Host "Optional: pip install llmlingua  # Enable input compression (~500MB)"
Write-Host "Rollback: python scripts\rollback.py"
