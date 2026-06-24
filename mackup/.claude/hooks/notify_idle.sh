#!/bin/bash
# Notify when Claude Code is waiting for user input

# Read the JSON data passed from Claude Code
input=$(cat)

# Skip if the Monitor tool is currently active for this session — Claude is
# "idle" only because it's watching a background process, not because it needs
# the user. The Monitor marker is written by monitor_marker.sh.
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
if [ -n "$session_id" ] && [ -f "/tmp/claude_monitoring_${session_id}" ]; then
  exit 0
fi

# Cooldown: only notify once per 5 minutes per session
COOLDOWN_FILE="/tmp/claude_idle_notified_$PPID"
if [ -f "$COOLDOWN_FILE" ]; then
  last=$(cat "$COOLDOWN_FILE")
  now=$(date +%s)
  if [ $((now - last)) -lt 300 ]; then
    exit 0
  fi
fi
date +%s > "$COOLDOWN_FILE"

# Get the path to the conversation transcript
transcript_path=$(echo "$input" | jq -r '.transcript_path')

# Expand tilde to $HOME (jq returns literal ~)
transcript_path="${transcript_path/#\~/$HOME}"

# Get the content of the last real user prompt in the session.
# Transcripts are JSONL. Content can be a plain string or an array of objects.
if [ -f "$transcript_path" ]; then
  summary=$(grep '"type":"user"' "$transcript_path" | jq -r '
    select(.type == "user")
    | select(.isMeta != true)
    | if (.message.content | type) == "string" then
        select(.message.content | startswith("<") | not)
        | select(.message.content | startswith("[Request interrupted") | not)
        | .message.content[0:100] | gsub("\n"; " ")
      elif (.message.content | type) == "array" then
        [.message.content[] | select(.type == "text") | .text] | last // empty
        | .[0:100] | gsub("\n"; " ")
      else
        empty
      end
  ' 2>/dev/null | tail -1)
fi

# Fallback if summary is empty
if [ -z "$summary" ]; then
  summary="Waiting for input"
fi

# Send the notification.
terminal-notifier -title "Claude Code: Idle" -message "$summary"

# Ring the tmux bell so the window tab goes red until viewed.
bash ~/.claude/hooks/highlight_window.sh
