#!/usr/bin/env bash
# Endurance Plan - Test Output Filter Hook (PreToolUse on Bash)
#
# Filters test runner output to show only failures + summary.
# Reduces test output from thousands of lines to ~10-50 lines.
#
# Hook config in settings.json:
# {
#   "hooks": {
#     "PreToolUse": [{
#       "matcher": "Bash",
#       "hooks": [{
#         "type": "command",
#         "command": "bash ~/.claude/hooks/filter-test-output.sh"
#       }]
#     }]
#   }
# }

input=$(cat)
cmd=$(echo "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

# Detect test runner commands
if [[ "$cmd" =~ ^(npm\ test|npx\ jest|npx\ vitest|pytest|python\ -m\ pytest|go\ test|cargo\ test|dotnet\ test|mvn\ test|gradle\ test) ]]; then
  # Wrap command to filter output: show only failures + summary
  filtered_cmd="$cmd 2>&1 | grep -E '(FAIL|FAILED|ERROR|error:|panic:|✗|✕|×|PASS|passed|failed|Total|Tests:|Suites:)' | head -80"
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\",\"updatedInput\":{\"command\":\"$filtered_cmd\"}}}"
else
  echo "{}"
fi
