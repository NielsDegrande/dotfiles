#!/usr/bin/env bash
# Delete developer caches that tools rebuild on their own.
#
# Usage:
#   scripts/clean_caches.sh          # preview: list what would go and its size
#   scripts/clean_caches.sh --yes    # actually delete
#
# Deleted (each is re-downloaded or rebuilt on the next build/install):
#   - Bazel: every output base (one per workspace, incl. build outputs), the
#     install base and the repository cache. Running Bazel servers are stopped
#     first, so the next build in each workspace starts cold.
#   - Bazel disk caches: every `--disk_cache=` path found in ~/.bazelrc and
#     /etc/bazel.bazelrc, plus the Lovable monorepo's (set in its .bazelrc).
#   - Go: build cache (GOCACHE) and module cache (GOMODCACHE).
#   - uv, npm, bun and gopls caches; Homebrew downloads and old versions.
#   - pnpm: unreferenced packages only (`pnpm store prune`). The store itself is
#     kept because node_modules folders can link into it.
#   - Playwright browsers and Xcode DerivedData.
#   - Nix: store paths no GC root references (`nix store gc`). Profile
#     generations are kept, so rollbacks still work.
#
# Not touched: project folders (node_modules, virtualenvs, build dirs),
# app caches under ~/Library/Caches, models, downloads, or anything else.

set -uo pipefail

apply=false
[[ "${1:-}" == "--yes" ]] && apply=true

total_kb=0
seen=$'\n'

human() { awk -v kb="$1" 'BEGIN { split("K M G T", u); i = 1; while (kb >= 1024 && i < 4) { kb /= 1024; i++ } printf "%.1f%s", kb, u[i] }'; }

size_kb() { du -sk "$1" 2>/dev/null | awk '{print $1}'; }

# Remove one directory, refusing anything that is not clearly a cache path.
remove_dir() {
  local dir="$1" label="$2" kb
  [[ -z "$dir" || "$dir" == "/" || "$dir" == "$HOME" || ! -d "$dir" ]] && return
  # The same cache can be reached via several names (e.g. `go env` and a default path).
  dir=$(cd "$dir" && pwd -P)
  [[ "$seen" == *$'\n'"$dir"$'\n'* ]] && return
  seen+="$dir"$'\n'
  kb=$(size_kb "$dir")
  total_kb=$((total_kb + ${kb:-0}))
  printf '%8s  %s  (%s)\n' "$(human "${kb:-0}")" "$dir" "$label"
  if $apply; then
    # Bazel and Go mark cache files read-only; make them deletable first.
    chmod -R u+w "$dir" 2>/dev/null
    rm -rf "$dir"
  fi
}

# Run a tool's own cleanup command when the tool is installed.
run_tool() {
  local label="$1"
  shift
  command -v "$1" >/dev/null 2>&1 || return
  printf '%8s  %s\n' "tool" "$label: $*"
  $apply && "$@" >/dev/null 2>&1
}

echo "== Bazel"
for bazel_root in "$HOME/Library/Caches/bazel/_bazel_$USER" "$HOME/.cache/bazel/_bazel_$USER"; do
  [[ -d "$bazel_root" ]] || continue
  for base in "$bazel_root"/*/; do
    base="${base%/}"
    pid_file="$base/server/server.pid.txt"
    if $apply && [[ -f "$pid_file" ]]; then
      kill "$(cat "$pid_file")" 2>/dev/null && sleep 1
    fi
    case "$(basename "$base")" in
      cache) label="repository cache" ;;
      install) label="install base" ;;
      *)
        workspace=$(grep -o '/[^ ]*' "$base/README" 2>/dev/null | head -1)
        label="output base for ${workspace:-an unknown or deleted workspace}"
        ;;
    esac
    remove_dir "$base" "$label"
  done
done
for rc in "$HOME/.bazelrc" /etc/bazel.bazelrc; do
  [[ -f "$rc" ]] || continue
  while read -r dir; do
    remove_dir "${dir/#\~/$HOME}" "Bazel disk cache from $rc"
  done < <(grep -oE -- '--disk_cache=[^ ]+' "$rc" | cut -d= -f2-)
done
remove_dir "$HOME/.cache/lovable/bazel/disk" "Bazel disk cache of the Lovable monorepo"

echo "== Go"
if command -v go >/dev/null 2>&1; then
  remove_dir "$(go env GOCACHE)" "Go build cache"
  remove_dir "$(go env GOMODCACHE)" "Go module cache"
fi
for dir in "$HOME/Library/Caches/go-build" "$HOME/.cache/go-build" "$HOME/go/pkg/mod" "$HOME/.cache/go/pkg/mod"; do
  remove_dir "$dir" "Go cache"
done
remove_dir "$HOME/Library/Caches/gopls" "gopls cache"

echo "== Other toolchains"
remove_dir "$HOME/.cache/uv" "uv cache"
remove_dir "$HOME/.npm/_cacache" "npm cache"
remove_dir "$HOME/.bun/install/cache" "bun cache"
remove_dir "$HOME/Library/Caches/ms-playwright" "Playwright browsers"
remove_dir "$HOME/Library/Developer/Xcode/DerivedData" "Xcode DerivedData"
run_tool "pnpm unreferenced packages" pnpm store prune
run_tool "Homebrew downloads and old versions" brew cleanup --prune=all
run_tool "Nix unreferenced store paths" nix store gc

echo
echo "Total: $(human "$total_kb") in directories."
if $apply; then
  echo "Deleted. Free space now: $(df -h "$HOME" | awk 'NR==2 {print $4}')"
else
  echo "Preview only (sizes exclude tool-run cleanups). Re-run with --yes to delete."
fi
