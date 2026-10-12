#!/bin/bash
# Notify when Claude Code needs the user (Notification hook). settings.json
# limits the matcher to types that need action; anything else is ignored here too.

# Read the JSON data passed from Claude Code.
input=$(cat)

notif_type=$(printf '%s' "$input" | jq -r '.notification_type // empty' 2>/dev/null)
case "$notif_type" in
  permission_prompt) title="Claude Code: Permission" ;;
  idle_prompt) title="Claude Code: Idle" ;;
  elicitation_dialog | elicitation_url_dialog | agent_needs_input) title="Claude Code: Input needed" ;;
  quota_auto_resume_stale | quota_auto_resume_disabled) title="Claude Code: Usage limit" ;;
  *) exit 0 ;;
esac

# shellcheck source=notify_lib.sh
if ! source "$HOME/.claude/hooks/notify_lib.sh" 2>/dev/null; then
  command -v terminal-notifier >/dev/null 2>&1 \
    && terminal-notifier -title "$title" -message "Waiting for input"
  exit 0
fi

session_id=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)
state_dir=$(cc_state_dir)

# idle_prompt is only a reminder (Stop already notified), so it gets the
# Monitor and cooldown suppression. Other types are blocking and always notify.
if [ "$notif_type" = "idle_prompt" ]; then
  # Skip while the Monitor tool is active: Claude is watching a background
  # process, not waiting on the user. monitor_marker.sh writes the marker and
  # the Stop hook clears it; the 4 h freshness window bounds a crashed session.
  if [ -n "$session_id" ] && [ -n "$(find "$state_dir/monitoring_${session_id}" -mmin -240 2>/dev/null)" ]; then
    exit 0
  fi

  # Cooldown: once per 5 minutes per session. Require a numeric value before
  # arithmetic, otherwise a crafted value like 'x[$(cmd)]' would be executed.
  COOLDOWN_FILE="$state_dir/idle_notified_${session_id:-$PPID}"
  if [ -f "$COOLDOWN_FILE" ]; then
    last=$(cat "$COOLDOWN_FILE")
    now=$(date +%s)
    if [[ "$last" =~ ^[0-9]+$ ]] && [ $((now - last)) -lt 300 ]; then
      exit 0
    fi
  fi
fi

cc_context "$input"

# Prefer the hook's own message (e.g. "Claude needs your permission to use
# Bash"): it says why the session is blocked. The generic idle text adds
# nothing, so use the last prompt for that one.
notif_msg=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
case "$notif_msg" in
  "" | *"waiting for your input"*) notif_msg="$CC_PROMPT" ;;
esac

# Stamp the cooldown only after successful delivery, so a lost notification
# (terminal-notifier missing) is not also suppressed for the next 5 minutes.
if cc_notify "$title" "$notif_msg" "Waiting for input" && [ -n "${COOLDOWN_FILE:-}" ]; then
  date +%s > "$COOLDOWN_FILE"
fi

# Ring the tmux bell so the window tab goes red until viewed.
bash ~/.claude/hooks/highlight_window.sh
