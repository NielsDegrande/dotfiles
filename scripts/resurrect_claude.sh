#!/usr/bin/env bash
# tmux-resurrect post-save-layout hook: make each Claude Code pane resume its
# own conversation on restore.
#
# A saved `claude -c` resumes the latest conversation in a directory, so panes
# sharing a directory would all open the same one. This rewrites each Claude
# pane to `claude ... --resume <sessionId>` in the session's directory, using
# the per-process records Claude Code keeps in ~/.claude/sessions/<pid>.json
# (internal format; panes without a record are left unchanged).
#
# Usage (set in .tmux.conf, resurrect passes the state file):
#   set -g @resurrect-hook-post-save-layout 'bash .../resurrect_claude.sh'

set -uo pipefail

state_file="$1"
sessions_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/sessions"
tmp="$state_file.claude"

# Print the session ID and cwd of the Claude process running in a pane.
claude_session() {
  local pane_pid="$1" ppid pid record
  while read -r ppid pid; do
    [[ "$ppid" == "$pane_pid" && -f "$sessions_dir/$pid.json" ]] || continue
    record=$(<"$sessions_dir/$pid.json")
    [[ "$record" =~ \"sessionId\":\"([^\"]+)\" ]] || continue
    echo "${BASH_REMATCH[1]}"
    [[ "$record" =~ \"cwd\":\"([^\"]+)\" ]] && echo "${BASH_REMATCH[1]}"
    return
  done < <(ps -ax -o ppid=,pid=)
}

# Drop continue/resume flags: the hook adds an explicit --resume.
strip_resume_args() {
  local args=() skip_value=false arg
  for arg in "$@"; do
    if $skip_value; then
      skip_value=false
      [[ "$arg" != -* ]] && continue
    fi
    case "$arg" in
      -c | --continue | --resume=*) ;;
      -r | --resume) skip_value=true ;;
      *) args+=("$arg") ;;
    esac
  done
  echo "${args[*]}"
}

sep=$'\x1f'
while IFS= read -r line; do
  # Split on a non-whitespace separator so empty fields (e.g. a blank pane title) are kept.
  IFS="$sep" read -r -a f <<<"${line//$'\t'/$sep}"
  full_command="${f[10]:-}"
  if [[ "${f[0]}" == "pane" && "$full_command" =~ ^:claude( |$) ]]; then
    pane_pid=$(tmux display -p -t "${f[1]}:${f[2]}.${f[5]}" '#{pane_pid}' 2>/dev/null)
    { read -r session_id; read -r cwd; } < <(claude_session "$pane_pid")
    if [[ -n "${session_id:-}" ]]; then
      read -r -a words <<<"${full_command#:}"
      kept=$(strip_resume_args "${words[@]:1}")
      f[10]=":claude ${kept:+$kept }--resume $session_id"
      # Resurrect escapes the first space of the directory field.
      [[ -n "${cwd:-}" ]] && f[7]=":${cwd/ /\\ }"
      line=$(IFS=$'\t'; echo "${f[*]}")
    fi
    unset session_id cwd
  fi
  printf '%s\n' "$line"
done <"$state_file" >"$tmp" && mv "$tmp" "$state_file"
