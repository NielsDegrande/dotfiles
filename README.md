# Dotfiles

Back up and restore configuration easily. Automatically install applications and binaries.

## Building blocks

- `Mackup` for managing most configuration and dotfiles.
- `Homebrew` for installing almost all applications (`cask` and `mas`) and binaries.
- `bash` scripts and some ubiquitous tools (e.g. `curl`) for the functionality not handled by the above.
- `git` and GitHub to version and store the artifacts.

## Usage

Restore on a new machine:

```bash
# Verify the presence of a GitHub SSH key (assume id_rsa).
[ -f "$HOME/.ssh/id_rsa" ] || echo "Configure SSH key required for cloning the dotfiles repository from GitHub. See KeePassXC."

# Use script to install all applications and binaries.
bash install.sh
```

Create parity with remote:

```bash
# Get the latest dotfiles.
cd "$HOME/git/dotfiles"
git pull  # Address conflicts as needed.

# Use script to restore and install.
bash install.sh

# Warn user.
echo "If changes were required, please push to remote. Be careful with credentials."
git status
```

Back up the current machine:

```bash

# Verify completeness of install.sh.
brew bundle dump ; cat Brewfile ; rm Brewfile
echo "Validate the above list for discrepancies with the relevant Brewfile."

ls $ZSH_CUSTOM/plugins
ls $ZSH_CUSTOM/themes
echo "Validate the above list for missing zsh plugins and themes."

hyper list
echo "Validate the above list for missing hyper plugins."

# Save code extensions.
code --list-extensions > "$HOME/.vscode/extensions.txt"

# Inspect for any discrepancies.
mackup backup --dry-run
echo "Ensure you do not push any secrets, keys or similar."

# Execute mackup.
mackup backup

# Push the latest.
cd "$HOME/git/dotfiles"
git add --all ; git commit --message "Back up machine configuration" ; git push
```

## Currently not supported

- Python environments: ensure proper dependency management at a project level,
  do not rely on the system environment(!).

## How to deal with data and other types of configuration

- `iCloud` for syncing most Apple related settings.
  TODO: Is this true? E.g. Caps Lock = ESC, hot corners, desktop background, etc.
- `Google Drive` and/or `Egnyte` for synchronizing data.
- `Firefox Sync` for synchronizing bookmarks, settings and extensions (not secrets!).
- `PyCharm` has version numbers in its path,
  see: <https://github.com/lra/mackup/blob/master/mackup/applications/pycharm.cfg.>.
  Currently using Pycharm Pro's Sync IDE Settings including plugin option.
