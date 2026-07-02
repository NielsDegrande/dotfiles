#!/bin/bash
# Notify when Claude Code finishes a turn (Stop hook).

# Read the JSON data passed from Claude Code.
input=$(cat)

# shellcheck source=notify_lib.sh
source ~/.claude/hooks/notify_lib.sh
cc_context "$input"

# Message: the actual last prompt is the useful signal. Fall back to the
# session name, then the tmux window name, then a generic string.
message="$CC_PROMPT"
[ -z "$message" ] && message="$CC_TITLE"
[ -z "$message" ] && message="$CC_WINDOW"
[ -z "$message" ] && message="Task completed"

# Subtitle: session name (which session finished). Fall back to tmux window.
# Drop it if it would just duplicate the message.
subtitle="$CC_TITLE"
[ -z "$subtitle" ] && subtitle="$CC_WINDOW"
[ "$subtitle" = "$message" ] && subtitle=""

args=(-title "Claude Code: Finished" -message "$message")
[ -n "$subtitle" ] && args+=(-subtitle "$subtitle")
terminal-notifier "${args[@]}"

# Ring the tmux bell so the window tab goes red until viewed.
bash ~/.claude/hooks/highlight_window.sh
