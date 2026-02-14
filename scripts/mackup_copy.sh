#!/bin/bash

#
# Backup and restore files that must be copied, not symlinked.
# Sandboxed apps (e.g. Maccy, Amphetamine, MeetingBar) break when their
# plists are symlinked. This script copies them to/from the dotfiles repo.
#
# Usage:
#   backup [--dry-run]  Copy from local machine to repo; report if changes.
#   restore            Copy from repo to local machine.
#

set -e

DOTFILES="${DOTFILES:-$HOME/git/dotfiles}"
PERSONAL_CFG="$DOTFILES/mackup/.mackup/personal.cfg"
MACKUP_DIR="$DOTFILES/mackup"

read_copy_only_entries() {
  local in_section=0
  while IFS= read -r line; do
    [[ $line =~ ^\[copy_only_files\] ]] && in_section=1 && continue
    [[ $line =~ ^\[ ]] && in_section=0
    if [[ $in_section -eq 1 && -n $line && ! $line =~ ^[[:space:]]*# ]]; then
      echo "$line"
    fi
  done < "$PERSONAL_CFG"
}

# Parse entry as path or path=app; output path and app (or empty) separated by \t.
parse_copy_only_entry() {
  local entry="$1"
  if [[ $entry == *"="* ]]; then
    echo "${entry%%=*}"$'\t'"${entry#*=}"
  else
    echo "$entry"$'\t'""
  fi
}

cmd_backup() {
  local dry_run=0
  [[ "${2:-}" == "--dry-run" ]] && dry_run=1

  local changed=0
  local entry
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    local rel_path
    rel_path=$(parse_copy_only_entry "$entry" | cut -f1)
    local src="$HOME/$rel_path"
    local dst="$MACKUP_DIR/$rel_path"

    if [[ ! -f "$src" ]]; then
      echo "Skipping (source missing): $rel_path"
      continue
    fi

    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
      continue
    fi

    if [[ $dry_run -eq 1 ]]; then
      echo "Would back up (changed): $rel_path"
    else
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      echo "Backed up (changed): $rel_path"
    fi
    changed=1
  done < <(read_copy_only_entries)

  if [[ $changed -eq 0 ]]; then
    echo "No changes to copy-only files."
  elif [[ $dry_run -eq 1 ]]; then
    echo "Dry run: no files copied. Run without --dry-run to back up."
  else
    echo "Run 'git add' and 'git commit' in $DOTFILES to persist."
  fi
}

cmd_restore() {
  local entry
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    local rel_path app
    rel_path=$(parse_copy_only_entry "$entry" | cut -f1)
    app=$(parse_copy_only_entry "$entry" | cut -f2)
    local src="$MACKUP_DIR/$rel_path"
    local dst="$HOME/$rel_path"

    if [[ ! -f "$src" ]]; then
      echo "Skipping (not in repo): $rel_path"
      continue
    fi

    if [[ -n "$app" ]] && [[ -d "$app" ]]; then
      killall "$(basename "$app" .app)" 2>/dev/null || true
    fi

    mkdir -p "$(dirname "$dst")"
    rm -f "$dst"
    cp "$src" "$dst"
    echo "Restored: $rel_path"

    if [[ -n "$app" ]] && [[ -d "$app" ]]; then
      open "$app"
    fi
  done < <(read_copy_only_entries)
}

case "${1:-}" in
  backup)
    cmd_backup "$@"
    ;;
  restore)
    cmd_restore
    ;;
  *)
    echo "Usage: $0 backup [--dry-run]|restore"
    exit 1
    ;;
esac
