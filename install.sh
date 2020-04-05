#!/bin/bash

: '

Install scripts for configuring a new machine.
One should also be able to runb this script on an existing machine

'


# Install developer tools for macOS.
xcode-select --install || true

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

# Install additional binaries and applications
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"  # oh-my-zsh.
command -v rustup || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  # Rust.
[ -d  "$ZSH_CUSTOM/themes/spaceship-prompt" ] || git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"  # Starship.

# Configure installed applications and binaries.
# hyper i hyper-one-dark  # Hyper theme.
hyper i hyper-solarized-light  # Hyper theme.
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme" || true  # Starship theme.
mkdir -p "$HOME/.vim/undodir"  # Vim undo directory.
