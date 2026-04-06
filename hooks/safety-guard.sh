#!/usr/bin/env bash
# Endurance Plan - Safety Guard Hook (PreToolUse on Bash)
# Blocks dangerous commands, warns on destructive ones.
# All JSON output via Python json.dumps — no string interpolation.

input=$(cat)

# Single Python script handles parsing + matching + safe JSON output
echo "$input" | python -c "
import sys, json, re

try:
    data = json.load(sys.stdin)
    cmd = data.get('tool_input', {}).get('command', '')
except Exception:
    print('{}')
    sys.exit(0)

BLOCKED = [
    r'rm -rf /',
    r'rm -rf /\*',
    r':\(\)\{ :\|:& \};:',
    r'mkfs\.',
    r'dd if=/dev/zero',
    r'> /dev/sda',
    r'chmod -R 777 /',
    r'curl.*\|.*bash',
    r'wget.*\|.*sh',
]

WARN = [
    r'git push.*--force',
    r'git reset --hard',
    r'git clean -fd',
    r'drop table',
    r'drop database',
    r'truncate table',
    r'DELETE FROM.*WHERE 1',
    r'npm publish',
    r'docker system prune -a',
]

for pattern in BLOCKED:
    if re.search(pattern, cmd, re.IGNORECASE):
        print(json.dumps({'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'permissionDecision': 'deny',
            'reason': f'[Safety Guard] Blocked dangerous command matching: {pattern}'
        }}))
        sys.exit(0)

for pattern in WARN:
    if re.search(pattern, cmd, re.IGNORECASE):
        print(json.dumps({'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'permissionDecision': 'ask',
            'reason': f'[Safety Guard] Potentially destructive command: {pattern}. Please confirm.'
        }}))
        sys.exit(0)

print('{}')
" 2>/dev/null || echo "{}"
