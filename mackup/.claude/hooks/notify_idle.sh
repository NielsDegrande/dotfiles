#!/bin/bash
# Notify when Claude Code is waiting for user input (Notification hook).

# Read the JSON data passed from Claude Code.
input=$(cat)

# shellcheck source=notify_lib.sh
if ! source "$HOME/.claude/hooks/notify_lib.sh" 2>/dev/null; then
  command -v terminal-notifier >/dev/null 2>&1 \
    && terminal-notifier -title "Claude Code: Idle" -message "Waiting for input"
  exit 0
fi

session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
state_dir=$(cc_state_dir)

# Skip if the Monitor tool is currently active for this session — Claude is
# "idle" only because it's watching a background process, not because it needs
# the user. The marker is written by monitor_marker.sh and cleared by the Stop
# hook; the freshness window (4 h) bounds how long a crashed session can
# suppress notifications while still covering long-running Monitors.
if [ -n "$session_id" ] && [ -n "$(find "$state_dir/monitoring_${session_id}" -mmin -240 2>/dev/null)" ]; then
  exit 0
fi

# Cooldown: only notify once per 5 minutes per session. Require a numeric
# value before arithmetic — otherwise a crafted value like 'x[$(cmd)]' in the
# file would be executed by the $(( )) below.
COOLDOWN_FILE="$state_dir/idle_notified_${session_id:-$PPID}"
if [ -f "$COOLDOWN_FILE" ]; then
  last=$(cat "$COOLDOWN_FILE")
  now=$(date +%s)
  if [[ "$last" =~ ^[0-9]+$ ]] && [ $((now - last)) -lt 300 ]; then
    exit 0
  fi
fi

cc_context "$input"

# Prefer the hook's own message (e.g. "Claude needs your permission to use
# Bash") — it says why the session is blocked. The generic idle variant adds
# nothing, so fall through to the last prompt for that one.
notif_msg=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
case "$notif_msg" in
  "" | *"waiting for your input"*) notif_msg="$CC_PROMPT" ;;
esac

# Stamp the cooldown only after successful delivery, so a lost notification
# (terminal-notifier missing) is not also suppressed for the next 5 minutes.
cc_notify "Claude Code: Idle" "$notif_msg" "Waiting for input" \
  && date +%s > "$COOLDOWN_FILE"

# Ring the tmux bell so the window tab goes red until viewed.
bash ~/.claude/hooks/highlight_window.sh
