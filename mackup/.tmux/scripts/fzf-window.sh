#!/bin/sh
# Homebrew binaries (fzf) are not on PATH when run from a tmux popup.
PATH="/opt/homebrew/bin:$PATH"
selection=$(tmux list-windows -F '#{window_index}: #{window_name} [#{b:pane_current_path}]#{?window_active, *,}' |
    fzf --reverse --no-sort) || exit 0
tmux select-window -t ":${selection%%:*}"
