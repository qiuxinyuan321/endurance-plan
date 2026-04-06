#!/usr/bin/env bash
# Endurance Plan - Safety Guard Hook (PreToolUse on Bash)
#
# Blocks dangerous commands that could cause irreversible damage.
# Inspired by OpenHands event-stream safety architecture.
#
# Hook config in settings.json:
# {
#   "hooks": {
#     "PreToolUse": [{
#       "matcher": "Bash",
#       "hooks": [{
#         "type": "command",
#         "command": "bash ~/.claude/hooks/safety-guard.sh"
#       }]
#     }]
#   }
# }

input=$(cat)
cmd=$(echo "$input" | python -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

# Dangerous patterns that should be blocked or warned
BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf /*"
  ":(){ :|:& };:"
  "mkfs\."
  "dd if=/dev/zero"
  "> /dev/sda"
  "chmod -R 777 /"
  "curl.*\\|.*bash"
  "wget.*\\|.*sh"
)

WARN_PATTERNS=(
  "git push.*--force"
  "git reset --hard"
  "git clean -fd"
  "drop table"
  "drop database"
  "truncate table"
  "DELETE FROM.*WHERE 1"
  "npm publish"
  "docker system prune -a"
)

# Check blocked patterns
for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$cmd" | grep -qiE "$pattern"; then
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"reason\":\"[Safety Guard] Blocked dangerous command matching: $pattern\"}}"
    exit 0
  fi
done

# Check warn patterns (allow but flag)
for pattern in "${WARN_PATTERNS[@]}"; do
  if echo "$cmd" | grep -qiE "$pattern"; then
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"ask\",\"reason\":\"[Safety Guard] Potentially destructive command: $pattern. Please confirm.\"}}"
    exit 0
  fi
done

# Pass through safe commands
echo "{}"
