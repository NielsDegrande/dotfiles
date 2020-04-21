#!/bin/bash

: '

Install scripts for configuring a new machine.
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
command -v brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Update Homebrew and upgrade formulae when this is not a 'clean install'.
brew update
brew upgrade  # Step required: if formulae not up-to-date, then brew returns non-0 upon re-install below.

# Install brew bundles.
brew bundle install --file brew/shared.Brewfile

# Machine specific installation and configuration.
case "$(HOSTNAME)" in
    "Nielss-MacBook-Air.local" )
        brew bundle install --file brew/macHome.Brewfile
        ;;
    "STK-XQ2PWJGH5" )
        brew bundle install --file brew/macWork.Brewfile
        ;;    
    * )
        echo "Machine name not recognized: no action taken."
        ;;
esac

# Remove outdated versions from the cellar.
brew cleanup

# Restore configuration.
ln -s "$HOME/git/dotfiles/mackup/.mackup.cfg" "$HOME/.mackup.cfg" || true
mackup restore --force

# Install additional binaries and applications
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"  # oh-my-zsh.
command -v rustup || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  # Rust.
[ -d  "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d  "$ZSH_CUSTOM/plugins/zsh-completions" ] || git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions"
[ -d  "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ] || git clone https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
[ -d  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ -d  "$ZSH_CUSTOM/themes/spaceship-prompt" ] || git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"

# Configure installed applications and binaries.
hyper install hyper-one-dark  # Hyper theme.
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme" || true  # Starship theme.
mkdir -p "$HOME/.vim/undodir"  # Vim undo directory.

# Install VS Code extensions.
cat "$HOME/.vscode/extensions.txt" | xargs  -I % sh -c "code --install-extension % || true"
