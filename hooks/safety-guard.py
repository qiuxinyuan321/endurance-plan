#!/usr/bin/env python
"""Endurance Plan - Safety Guard Hook (PreToolUse on Bash)
Blocks dangerous commands, warns on destructive ones.
All JSON output via json.dumps — injection-safe.
"""
import sys
import json
import re

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


def main():
    try:
        data = json.load(sys.stdin)
        cmd = data.get('tool_input', {}).get('command', '')
    except Exception:
        print('{}')
        return

    for pattern in BLOCKED:
        if re.search(pattern, cmd, re.IGNORECASE):
            print(json.dumps({'hookSpecificOutput': {
                'hookEventName': 'PreToolUse',
                'permissionDecision': 'deny',
                'reason': f'[Safety Guard] Blocked dangerous command matching: {pattern}'
            }}))
            return

    for pattern in WARN:
        if re.search(pattern, cmd, re.IGNORECASE):
            print(json.dumps({'hookSpecificOutput': {
                'hookEventName': 'PreToolUse',
                'permissionDecision': 'ask',
                'reason': f'[Safety Guard] Potentially destructive: {pattern}. Please confirm.'
            }}))
            return

    print('{}')


if __name__ == '__main__':
    main()
