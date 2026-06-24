#!/bin/bash
# Track when the Monitor tool is active for the current session.
# notify_idle.sh checks this marker and skips the idle notification while
# Monitor is running (otherwise watching a process pings the user every time
# Claude becomes "idle" mid-monitor).
#
# Wire as PreToolUse and PostToolUse (and PostToolUseFailure) on matcher Monitor.

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
event=$(echo "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)

[ -z "$session_id" ] && exit 0

marker="/tmp/claude_monitoring_${session_id}"

case "$event" in
  PreToolUse)
    touch "$marker"
    ;;
  PostToolUse|PostToolUseFailure)
    rm -f "$marker"
    ;;
esac

exit 0
