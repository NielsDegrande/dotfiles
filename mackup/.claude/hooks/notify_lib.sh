#!/bin/bash
# Shared context helper for Claude Code notification hooks.
#
# Claude Code writes two clean records into every session transcript (JSONL):
#   {"type":"ai-title","aiTitle":"<session name>"}      <- AI-generated session name
#   {"type":"last-prompt","lastPrompt":"<user prompt>"} <- last real user prompt, pre-cleaned
# These are far more reliable than re-deriving the prompt from raw "user"
# records (most turns END on a tool_result-only user record, which has no text
# and yields an empty summary -> the old "Task completed" fallback).
#
# Usage:  source ~/.claude/hooks/notify_lib.sh; cc_context "$input"
# Sets (globals):
#   CC_TITLE   session name (ai-title), or ""
#   CC_PROMPT  last user prompt, whitespace-collapsed and length-capped, or ""
#   CC_WINDOW  tmux window name for this pane, or ""

cc_context() {
  local input="$1"
  local transcript_path

  CC_TITLE=""
  CC_PROMPT=""
  CC_WINDOW=""

  transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
  # Expand tilde to $HOME (jq returns a literal ~).
  transcript_path="${transcript_path/#\~/$HOME}"

  if [ -f "$transcript_path" ]; then
    CC_TITLE=$(grep '"type":"ai-title"' "$transcript_path" 2>/dev/null | tail -1 \
      | jq -r '.aiTitle // empty' 2>/dev/null)
    CC_PROMPT=$(grep '"type":"last-prompt"' "$transcript_path" 2>/dev/null | tail -1 \
      | jq -r '.lastPrompt // empty' 2>/dev/null)
  fi

  # Collapse newlines/whitespace and cap length so the notification stays legible.
  CC_PROMPT=$(printf '%s' "$CC_PROMPT" | tr '\n' ' ' | tr -s ' ' | cut -c1-150)
  CC_TITLE=$(printf '%s' "$CC_TITLE" | tr '\n' ' ' | tr -s ' ' | cut -c1-100)

  # tmux window name. Claude Code strips $TMUX from hook env but preserves
  # $TMUX_PANE; the default socket is reachable without $TMUX set.
  if [ -n "${TMUX_PANE:-}" ] && command -v tmux >/dev/null 2>&1; then
    CC_WINDOW=$(tmux display-message -p -t "$TMUX_PANE" '#{window_name}' 2>/dev/null)
  fi
}
