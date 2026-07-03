#!/bin/bash

: '

Install script for configuring a new machine.
One should also be able to run this script on an existing machine

'

# Ensure script exits upon intermediate failure.
set -e

# Install developer tools for macOS.
xcode-select --install || true

# Get the latest dotfiles.
# Clone over HTTPS: a fresh machine has no SSH key yet (ssh is not restored by mackup).
mkdir -p "$HOME/git"
git clone https://github.com/NielsDegrande/dotfiles.git "$HOME/git/dotfiles" || true
cd "$HOME/git/dotfiles"

# Install Homebrew.
command -v brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Freshly installed brew is not yet on bash's PATH on Apple Silicon.
command -v brew >/dev/null || eval "$(/opt/homebrew/bin/brew shellenv)"

# Update Homebrew and upgrade formulae when this is not a 'clean install'.
brew update
brew upgrade # Step required: if formulae not up-to-date, then brew returns non-0 upon re-install below.

# Install brew bundles.
brew bundle install --file brew/base.Brewfile

# Remove outdated versions from the cellar.
brew cleanup

# Ensure docker can find compose and buildx: install as plugin.
mkdir -p ~/.docker/cli-plugins
ln -sfn "$(brew --prefix)/opt/docker-compose/bin/docker-compose" ~/.docker/cli-plugins/docker-compose
ln -sfn "$(brew --prefix)/opt/docker-buildx/bin/docker-buildx" ~/.docker/cli-plugins/docker-buildx

# Restore configuration.
ln -s "$HOME/git/dotfiles/mackup/.mackup.cfg" "$HOME/.mackup.cfg" || true
mackup link --force

# Restore copy-only files as symlinks break sandboxed apps.
bash "$HOME/git/dotfiles/scripts/mackup_copy.sh" restore

# Load mac configuration (this file should hold all mac config).
bash "$HOME/.macos"

# Install additional binaries and applications.
# oh-my-zsh. Unattended: RUNZSH=no avoids exec'ing zsh mid-script, KEEP_ZSHRC=yes
# stops the installer from renaming the mackup-managed ~/.zshrc symlink.
[ -d "$HOME/.oh-my-zsh" ] || RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# NOTE: oh-my-zsh plugins and themes are not submodules as they are nested under `.oh-my-zsh/custom` which we install above.
#       Using submodules in dotfiles for the below, is causing problems as oh-my-zsh is a git repo itself.
# ZSH_CUSTOM only exists inside a zsh session with oh-my-zsh loaded; default it here.
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ -d "$ZSH_CUSTOM/plugins/fzf-tab" ] || git clone https://github.com/Aloxaf/fzf-tab.git "$ZSH_CUSTOM/plugins/fzf-tab"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-completions" ] || git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ -d "$ZSH_CUSTOM/plugins/you-should-use" ] || git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"

# Install tmux package manager.
[ -d "$HOME/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# Add cron jobs (preserve unrelated entries, replace any previous archiver line).
# Requires additional permissions to give /usr/sbin/cron full disk access.
# The `|| true` matters: under set -e, a failing grep (no crontab yet, or no
# other entries) would otherwise abort the subshell before the echo and
# install an empty crontab.
(crontab -l 2>/dev/null | grep -v notes_archiver.sh || true; echo "0 11 * * * $HOME/git/dotfiles/scripts/notes_archiver.sh") | crontab -

# Install Alacritty terminfo.
# TODO: Required? Test before.
curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -

# Compile and install VerticalMonitorLayout.
# Source: https://github.com/alin23/mac-utils (MIT, Alin Panaitiu).
bin=/usr/local/bin/VerticalMonitorLayout
sudo mkdir -p -m 0755 /usr/local/bin
# Build in a private mktemp dir (mode 0700, owned by us) rather than a
# predictable /tmp path, so no other local user can swap the binary between
# compile and the privileged install.
build_dir=$(mktemp -d)
swiftc -framework Cocoa "$HOME/git/dotfiles/scripts/VerticalMonitorLayout.swift" -o "$build_dir/VerticalMonitorLayout"
sudo install -m 0755 "$build_dir/VerticalMonitorLayout" "$bin"
rm -rf "$build_dir"

# Set default applications.
infat --config ~/.config/infat/config.toml

# Symlink CLAUDE.
mkdir -p "$HOME/.claude"
ln -sfn "$HOME/git/dotfiles/mackup/.agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
# BSD ln -sfn nests a junk link inside an existing real directory (Claude Code
# pre-creates ~/.claude/skills); replace it only when empty or already a link.
if [ ! -d "$HOME/.claude/skills" ] || [ -L "$HOME/.claude/skills" ] || rmdir "$HOME/.claude/skills" 2>/dev/null; then
  ln -sfn "$HOME/.agents/skills" "$HOME/.claude/skills"
else
  echo "Skipped ~/.claude/skills symlink: existing non-empty directory."
fi
