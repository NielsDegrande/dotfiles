#!/bin/bash
# Track when the Monitor tool is active for the current session.
# notify_idle.sh checks this marker and skips the idle notification while
# Monitor is running (otherwise watching a process pings the user every time
# Claude becomes "idle" mid-monitor).
#
# Wired as PreToolUse and PostToolUse on matcher Monitor. Cleanup also happens
# in notify_on_finish.sh (Stop hook) and via a freshness check in
# notify_idle.sh, so a crashed or interrupted Monitor cannot suppress idle
# notifications forever.

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
event=$(echo "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)

[ -z "$session_id" ] && exit 0

# shellcheck source=notify_lib.sh
source "$HOME/.claude/hooks/notify_lib.sh" 2>/dev/null || exit 0
marker="$(cc_state_dir)/monitoring_${session_id}"

case "$event" in
  PreToolUse)
    touch "$marker"
    ;;
  PostToolUse)
    rm -f "$marker"
    ;;
esac

exit 0
