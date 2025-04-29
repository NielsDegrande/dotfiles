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
mkdir -p "$HOME/git"
git clone git@github.com:NielsDegrande/dotfiles.git "$HOME/git" || true
cd "$HOME/git/dotfiles"

# Install Homebrew.
command -v brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update Homebrew and upgrade formulae when this is not a 'clean install'.
brew update
brew upgrade # Step required: if formulae not up-to-date, then brew returns non-0 upon re-install below.

# Install brew bundles.
brew bundle install --file brew/base.Brewfile

# Remove outdated versions from the cellar.
brew cleanup

# Ensure docker can find compose and buildx: install as plugin.
mkdir -p ~/.docker/cli-plugins
ln -sfn $(brew --prefix)/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ln -sfn $(brew --prefix)/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx

# Restore configuration.
ln -s "$HOME/git/dotfiles/mackup/.mackup.cfg" "$HOME/.mackup.cfg" || true
mackup restore --force

# Load mac configuration (this file should hold all mac config).
bash "$HOME/.macos"

# Install additional binaries and applications.
# oh-my-zsh.
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# NOTE: oh-my-zsh plugins and themes are not submodules as they are nested under `.oh-my-zsh/custom` which we install above.
#       Using submodules in dotfiles for the below, is causing problems as oh-my-zsh is a git repo itself.
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-completions" ] || git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions"
[ -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ] || git clone https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ -d "$ZSH_CUSTOM/plugins/you-should-use" ] || git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"

# Install alacritty theme.
[ -d "$HOME/.config/alacritty/themes" ] || (mkdir -p "$HOME/.config/alacritty/themes" && curl https://raw.githubusercontent.com/alacritty/alacritty-theme/master/themes/one_dark.yaml >~/.config/alacritty/themes/one_dark.yaml)

# Install tmux plugins.
[ -d "~/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install fzf keybindings.
/opt/homebrew/opt/fzf/install

# Add cron jobs.
# Requires additional permissions to give crontab full disk access.
echo "* 11 * * * /Users/degrandeniels/git/dotfiles/scripts/notes_archiver.sh" | crontab -

# Install Alacritty terminfo.
curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -

# Set default applications.
infat --config ~/.config/infat/config.toml
