#!/bin/bash
# Notify when Claude Code calls AskUserQuestion (PreToolUse hook).
# AskUserQuestion does not trigger the Notification hook, so we hook PreToolUse
# directly to alert and ring the tmux bell.

input=$(cat)

question=$(echo "$input" | jq -r '.tool_input.questions[0].question // empty' 2>/dev/null)
[ -z "$question" ] && question="Awaiting answer"
summary=$(echo "$question" | tr '\n' ' ' | cut -c1-200)

terminal-notifier -title "Claude Code: Question" -message "$summary"

bash ~/.claude/hooks/highlight_window.sh
