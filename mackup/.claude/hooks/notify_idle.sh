#!/bin/bash
# Notify when Claude Code is waiting for user input (Notification hook).

# Read the JSON data passed from Claude Code.
input=$(cat)

# Skip if the Monitor tool is currently active for this session — Claude is
# "idle" only because it's watching a background process, not because it needs
# the user. The Monitor marker is written by monitor_marker.sh.
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
if [ -n "$session_id" ] && [ -f "/tmp/claude_monitoring_${session_id}" ]; then
  exit 0
fi

# Cooldown: only notify once per 5 minutes per session.
COOLDOWN_FILE="/tmp/claude_idle_notified_$PPID"
if [ -f "$COOLDOWN_FILE" ]; then
  last=$(cat "$COOLDOWN_FILE")
  now=$(date +%s)
  if [ $((now - last)) -lt 300 ]; then
    exit 0
  fi
fi
date +%s > "$COOLDOWN_FILE"

# shellcheck source=notify_lib.sh
source ~/.claude/hooks/notify_lib.sh
cc_context "$input"

# Message: the last prompt gives context on what Claude is blocked on. Fall
# back to the session name, then the tmux window name, then a generic string.
message="$CC_PROMPT"
[ -z "$message" ] && message="$CC_TITLE"
[ -z "$message" ] && message="$CC_WINDOW"
[ -z "$message" ] && message="Waiting for input"

# Subtitle: session name (which session needs input). Fall back to tmux window.
subtitle="$CC_TITLE"
[ -z "$subtitle" ] && subtitle="$CC_WINDOW"
[ "$subtitle" = "$message" ] && subtitle=""

args=(-title "Claude Code: Idle" -message "$message")
[ -n "$subtitle" ] && args+=(-subtitle "$subtitle")
terminal-notifier "${args[@]}"

# Ring the tmux bell so the window tab goes red until viewed.
bash ~/.claude/hooks/highlight_window.sh
