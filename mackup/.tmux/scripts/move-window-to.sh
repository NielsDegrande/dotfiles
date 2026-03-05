#!/bin/sh
T=$1
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
tmux set-option -g renumber-windows on
