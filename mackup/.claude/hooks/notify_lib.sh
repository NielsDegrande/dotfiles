#!/bin/bash
# Shared context helper for Claude Code notification hooks.
#
# Claude Code writes two clean records into session transcripts (JSONL):
#   {"type":"ai-title","aiTitle":"<session name>"}      <- AI-generated session name
#   {"type":"last-prompt","lastPrompt":"<user prompt>"} <- last real user prompt, pre-cleaned
# last-prompt is present in practice; ai-title only appears once the session
# has been named, so CC_TITLE is often empty and callers must not rely on it.
# These are far more reliable than re-deriving the prompt from raw "user"
# records (most turns END on a tool_result-only user record, which has no text
# and yields an empty summary -> the old "Task completed" fallback).
#
# Usage:  source ~/.claude/hooks/notify_lib.sh
#         cc_context "$input"
#         cc_notify "Claude Code: Finished" "$CC_PROMPT" "Task completed"
# cc_context sets (globals):
#   CC_TITLE       session name (ai-title), or ""
#   CC_PROMPT      last user prompt, whitespace-collapsed and length-capped, or ""
#   CC_WINDOW      tmux window name for this pane, or ""
#   CC_SESSION_ID  Claude Code session id, or ""

# cc_state_dir: create and echo the private per-user state dir (mode 0700) so
# no other local user can pre-plant or symlink state files.
cc_state_dir() {
  local dir
  dir="${TMPDIR:-/tmp}/claude-$(id -u)"
  mkdir -p "$dir" && chmod 700 "$dir"
  printf '%s' "$dir"
}

# cc_squash <text> <max-chars>
# Collapse newlines/whitespace and cap length so notifications stay legible.
# Uses a bash substring (character-based) rather than cut -c (byte-based on
# macOS), so multibyte UTF-8 text is never split mid-character.
cc_squash() {
  local text
  text=$(printf '%s' "$1" | tr '\n' ' ' | tr -s ' ')
  printf '%s' "${text:0:$2}"
}

cc_context() {
  local input="$1"
  local transcript_path

  CC_TITLE=""
  CC_PROMPT=""
  CC_WINDOW=""

  CC_SESSION_ID=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)

  transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
  # Expand tilde to $HOME (jq returns a literal ~).
  transcript_path="${transcript_path/#\~/$HOME}"

  if [ -f "$transcript_path" ]; then
    CC_TITLE=$(grep '"type":"ai-title"' "$transcript_path" 2>/dev/null | tail -1 \
      | jq -r '.aiTitle // empty' 2>/dev/null)
    CC_PROMPT=$(grep '"type":"last-prompt"' "$transcript_path" 2>/dev/null | tail -1 \
      | jq -r '.lastPrompt // empty' 2>/dev/null)
  fi

  CC_PROMPT=$(cc_squash "$CC_PROMPT" 150)
  CC_TITLE=$(cc_squash "$CC_TITLE" 100)

  # tmux window name. Claude Code strips $TMUX from hook env but preserves
  # $TMUX_PANE; the default socket is reachable without $TMUX set.
  if [ -n "${TMUX_PANE:-}" ] && command -v tmux >/dev/null 2>&1; then
    CC_WINDOW=$(tmux display-message -p -t "$TMUX_PANE" '#{window_name}' 2>/dev/null)
  fi
}

# cc_notify <title> <message> <fallback>
# Send a terminal-notifier alert. Message falls back to the session name, then
# the tmux window name, then <fallback>. Subtitle is the session name (or tmux
# window), dropped when it would just duplicate the message. Notifications are
# grouped per session so repeats replace each other instead of stacking.
# Returns non-zero when nothing was delivered (terminal-notifier missing) so
# callers can decide whether to record the attempt.
cc_notify() {
  local title="$1" message="$2" fallback="$3" subtitle

  [ -z "$message" ] && message="$CC_TITLE"
  [ -z "$message" ] && message="$CC_WINDOW"
  [ -z "$message" ] && message="$fallback"

  subtitle="$CC_TITLE"
  [ -z "$subtitle" ] && subtitle="$CC_WINDOW"
  [ "$subtitle" = "$message" ] && subtitle=""

  command -v terminal-notifier >/dev/null 2>&1 || return 1

  local args=(-title "$title" -message "$message" -group "claude-code-${CC_SESSION_ID:-default}")
  [ -n "$subtitle" ] && args+=(-subtitle "$subtitle")
  terminal-notifier "${args[@]}"
}
