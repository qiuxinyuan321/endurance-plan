#!/usr/bin/env python
"""Endurance Plan - Test Output Filter Hook (PreToolUse on Bash)
Wraps test commands to show only failures + summary.
All JSON output via json.dumps — injection-safe.
"""
import sys
import json
import re

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

GREP_PATTERN = 'FAIL|FAILED|ERROR|error:|panic:|PASS|passed|failed|Total|Tests:|Suites:'
MAX_LINES = 80


def main():
    try:
        data = json.load(sys.stdin)
        cmd = data.get('tool_input', {}).get('command', '')
    except Exception:
        print('{}')
        return

    is_test = any(re.match(p, cmd) for p in TEST_PREFIXES)

    if is_test:
        filtered = f'{cmd} 2>&1 | grep -E "({GREP_PATTERN})" | head -{MAX_LINES}'
        print(json.dumps({'hookSpecificOutput': {
            'hookEventName': 'PreToolUse',
            'permissionDecision': 'allow',
            'updatedInput': {'command': filtered}
        }}))
    else:
        print('{}')


if __name__ == '__main__':
    main()
