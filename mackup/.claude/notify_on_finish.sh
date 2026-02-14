#!/bin/bash
# Make this executable with: chmod +x ~/.claude/notify_on_finish.sh

# Read the JSON data passed from Claude Code
input=$(cat)

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
  summary="Task completed"
fi

# Send the notification with context (using terminal-notifier with Claude icon).
terminal-notifier -title "Claude Code: Finished" -message "$summary"

# Ring the terminal bell so tmux highlights the window title red in the status bar.
# The hook may run with stdout redirected; use tmux to run the bell in the pane's window.
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
  tmux split-window -h -d -t "$TMUX_PANE" "printf '\\a'; exit"
else
  printf '\a' > /dev/tty 2>/dev/null || printf '\a'
fi
