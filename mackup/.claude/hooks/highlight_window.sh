#!/bin/bash
# Ring the terminal bell so tmux highlights the window title red.
#
# tmux processes BEL written to a pane's slave tty as if the in-pane app
# emitted it → window_bell_flag → window-status-bell-style (red, per
# ~/.tmux.conf). tmux clears the flag automatically when the user views the
# window, which is the behavior we want.
#
# Claude Code strips $TMUX from hook env but preserves $TMUX_PANE, so the
# usual `[ -n "$TMUX" ]` guard always fails for hook scripts. Gate on
# $TMUX_PANE only; tmux's default socket is reachable without $TMUX set.

if [ -n "${TMUX_PANE:-}" ] && command -v tmux >/dev/null 2>&1; then
  pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
  if [ -n "$pane_tty" ] && printf '\a' > "$pane_tty" 2>/dev/null; then
    exit 0
  fi
fi

# No fallback: hooks have no controlling tty, so a BEL to /dev/tty or stdout
# never reaches a terminal. Outside tmux there is simply nothing to ring.
exit 0
