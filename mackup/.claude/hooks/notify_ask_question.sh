#!/bin/bash
# Notify when Claude Code calls AskUserQuestion (PreToolUse hook).
# AskUserQuestion does not trigger the Notification hook, so we hook PreToolUse
# directly to alert and ring the tmux bell.

input=$(cat)

question=$(echo "$input" | jq -r '.tool_input.questions[0].question // empty' 2>/dev/null)

# shellcheck source=notify_lib.sh
if ! source "$HOME/.claude/hooks/notify_lib.sh" 2>/dev/null; then
  command -v terminal-notifier >/dev/null 2>&1 \
    && terminal-notifier -title "Claude Code: Question" -message "${question:-Awaiting answer}"
  exit 0
fi
cc_context "$input"

message=$(cc_squash "$question" 200)
cc_notify "Claude Code: Question" "$message" "Awaiting answer"

bash ~/.claude/hooks/highlight_window.sh
