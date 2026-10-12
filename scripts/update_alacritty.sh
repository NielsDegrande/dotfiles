#!/usr/bin/env bash
# Install or update Alacritty from its GitHub releases.
#
# Homebrew disabled the cask because Alacritty is not notarized by Apple, so
# GitHub releases are the update channel. Also installs the matching terminfo,
# which the cask used to link (alacritty.toml sets TERM=alacritty).
#
# Usage:
#   scripts/update_alacritty.sh          # latest release
#   scripts/update_alacritty.sh v0.17.0  # specific release

set -euo pipefail

repo=https://github.com/alacritty/alacritty
app=/Applications/Alacritty.app

if command -v brew >/dev/null && brew list --cask alacritty >/dev/null 2>&1; then
  echo "Alacritty is still managed by the Homebrew cask. Remove it once, then rerun:"
  echo "  brew uninstall --cask alacritty"
  exit 1
fi

tag="${1:-}"
if [[ -z "$tag" ]]; then
  # /releases/latest redirects to /releases/tag/<tag>; avoids the API rate limit.
  tag=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "$repo/releases/latest")
  tag="${tag##*/}"
fi

installed=$(defaults read "$app/Contents/Info" CFBundleShortVersionString 2>/dev/null || true)
if [[ "v$installed" == "$tag" ]]; then
  echo "Alacritty $tag is up to date."
  exit 0
fi
echo "Installing Alacritty $tag (installed: ${installed:-none})."

tmp=$(mktemp -d)
trap 'hdiutil detach -quiet "$tmp/mnt" 2>/dev/null || true; rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/Alacritty.dmg" "$repo/releases/download/$tag/Alacritty-$tag.dmg"
curl -fsSL -o "$tmp/alacritty.info" "$repo/releases/download/$tag/alacritty.info"

hdiutil attach -quiet -nobrowse -readonly -mountpoint "$tmp/mnt" "$tmp/Alacritty.dmg"
ditto "$tmp/mnt/Alacritty.app" "$tmp/Alacritty.app"
codesign --verify --deep --strict "$tmp/Alacritty.app"
xattr -dr com.apple.quarantine "$tmp/Alacritty.app" 2>/dev/null || true

# Swap in place: a running Alacritty keeps working until it is restarted.
rm -rf "$app"
mv "$tmp/Alacritty.app" "$app"

tic -x "$tmp/alacritty.info"

echo "Installed Alacritty $tag. Restart Alacritty to use it."
