#!/bin/bash
# Notify when Claude Code finishes a turn (Stop hook).

# Read the JSON data passed from Claude Code.
input=$(cat)

# shellcheck source=notify_lib.sh
if ! source "$HOME/.claude/hooks/notify_lib.sh" 2>/dev/null; then
  command -v terminal-notifier >/dev/null 2>&1 \
    && terminal-notifier -title "Claude Code: Finished" -message "Task completed"
  exit 0
fi
cc_context "$input"

# The turn is over: clear any Monitor marker so idle notifications resume even
# when the PostToolUse cleanup was missed (crash, interrupt).
[ -n "$CC_SESSION_ID" ] && rm -f "$(cc_state_dir)/monitoring_${CC_SESSION_ID}"

# The last prompt is the useful signal; cc_notify falls back to the session
# name, then the tmux window name, then the generic string.
cc_notify "Claude Code: Finished" "$CC_PROMPT" "Task completed"

# Ring the tmux bell so the window tab goes red until viewed.
bash ~/.claude/hooks/highlight_window.sh
