#!/usr/bin/env bash
# Endurance Plan - Test Output Filter Hook (PreToolUse on Bash)
# Wraps test commands to show only failures + summary.
# All JSON output via Python json.dumps — no string interpolation.

input=$(cat)

echo "$input" | python -c "
import sys, json, re

try:
    data = json.load(sys.stdin)
    cmd = data.get('tool_input', {}).get('command', '')
except Exception:
    print('{}')
    sys.exit(0)

TEST_PREFIXES = [
    r'^npm test',
    r'^npx jest',
    r'^npx vitest',
    r'^pytest',
    r'^python -m pytest',
    r'^python3 -m pytest',
    r'^go test',
    r'^cargo test',
    r'^dotnet test',
    r'^mvn test',
    r'^gradle test',
]

is_test = any(re.match(p, cmd) for p in TEST_PREFIXES)

if is_test:
    grep_pattern = 'FAIL|FAILED|ERROR|error:|panic:|PASS|passed|failed|Total|Tests:|Suites:'
    filtered = cmd + ' 2>&1 | grep -E \"(' + grep_pattern + ')\" | head -80'
    print(json.dumps({'hookSpecificOutput': {
        'hookEventName': 'PreToolUse',
        'permissionDecision': 'allow',
        'updatedInput': {'command': filtered}
    }}))
else:
    print('{}')
" 2>/dev/null || echo "{}"
