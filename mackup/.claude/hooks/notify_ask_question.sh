#!/bin/bash
# Notify when Claude Code calls AskUserQuestion (PreToolUse hook).
# AskUserQuestion does not trigger the Notification hook, so we hook PreToolUse
# directly to alert and ring the tmux bell.

input=$(cat)

question=$(echo "$input" | jq -r '.tool_input.questions[0].question // empty' 2>/dev/null)
[ -z "$question" ] && question="Awaiting answer"
message=$(echo "$question" | tr '\n' ' ' | cut -c1-200)

# shellcheck source=notify_lib.sh
source ~/.claude/hooks/notify_lib.sh
cc_context "$input"

# Subtitle: session name (which session is asking). Fall back to tmux window.
subtitle="$CC_TITLE"
[ -z "$subtitle" ] && subtitle="$CC_WINDOW"

args=(-title "Claude Code: Question" -message "$message")
[ -n "$subtitle" ] && args+=(-subtitle "$subtitle")
terminal-notifier "${args[@]}"

bash ~/.claude/hooks/highlight_window.sh
