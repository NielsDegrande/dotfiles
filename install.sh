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
# Recurse submodules to download VIM plugins. The `-j8` option parallelizes that.
git clone --recurse-submodules -j8 git@github.com:NielsDegrande/dotfiles.git "$HOME/git" || true
cd "$HOME/git/dotfiles"

# Load mac configuration (this file should hold all mac config).
bash macos.sh

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
        # Install brew bundle for home.
        brew bundle install --file brew/macHome.Brewfile
        # Set screenshot location to Downloads.
        defaults write com.apple.screencapture location "$HOME/Downloads"
        ;;
    "STK-3G6T093VW" )
        # Install brew bundle for work.
        brew bundle install --file brew/macWork.Brewfile
        # Set screenshot location to Downloads.
        defaults write com.apple.screencapture location "$HOME/Library/CloudStorage/OneDrive-TheBostonConsultingGroup,Inc/Downloads"
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

# Install additional binaries and applications.
# oh-my-zsh.
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# NOTE: oh-my-zsh plugins and themes are not submodules as they are nested under `.oh-my-zsh/custom` which we install above.
#       Using submodules in dotfiles for the below, is causing problems as oh-my-zsh is a git repo itself.
[ -d  "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d  "$ZSH_CUSTOM/plugins/zsh-completions" ] || git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions"
[ -d  "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ] || git clone https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
[ -d  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Install tmux plugins.
[ -d  "~/.tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Configure installed applications and binaries.
# Vim undo directory.
mkdir -p "$HOME/.vim/undodir"

# Install VS Code extensions.
cat "$HOME/.vscode/extensions.txt" | xargs  -I % sh -c "code --install-extension % || true"

# Install fzf keybindings.
/opt/homebrew/opt/fzf/install
