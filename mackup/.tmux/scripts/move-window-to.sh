#!/bin/sh
# Move the current tmux window to index $1 by successive swaps.
T=$1
case "$T" in '' | *[!0-9]*) exit 1 ;; esac
# Clamp to the last window index so out-of-range targets don't error mid-loop.
last=$(tmux list-windows -F '#{window_index}' | tail -1)
[ "$T" -gt "$last" ] && T=$last
C=$(tmux display-message -p '#{window_index}')
[ "$C" -eq "$T" ] && exit 0
if [ "$C" -gt "$T" ]; then
    while [ "$C" -gt "$T" ]; do
        tmux swap-window -d -s ":$C" -t ":$((C-1))"
        C=$((C-1))
    done
else
    while [ "$C" -lt "$T" ]; do
        tmux swap-window -d -s ":$C" -t ":$((C+1))"
        C=$((C+1))
    done
fi
tmux select-window -t ":$T"
