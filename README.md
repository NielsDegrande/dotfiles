# Dotfiles
Back up and restore configuration easily. Automatically install applications and binaries.

## Prerequisites
- `Mackup` for managing most configuration and dotfiles.
- `Homebrew` for installing almost all applications (`cask` and `mas`) and binaries.
- `bash` scripts and some ubiquitous tools (e.g. `curl`) for the functionality not handled by the above.
- `git` and GitHub to version and store the artifacts.

## Usage

Restore on a new machine:
```bash
# Get the latest dotfiles.
mkdir -p "$HOME/git"
gcl git@github.com:NielsDegrande/dotfiles.git

# Use script to install all applications and binaries.
bash install.sh

# Restore configuration.
mv "$HOME/git/dotfiles/mackup/.mackup.cfg" "$HOME/.mackup.cfg"
mackup restore
mackup backup
```

Create parity with remote:
```bash
# Get the latest dotfiles.
cd "$HOME/git/dotfiles"
gl  # Address conflicts as needed.

# Use script to restore and install.
bash install.sh

# Warn user.
echo "If changes were required, please push to remote. Be careful with credentials."
gst
```

To back up the existing machine:
```bash
# Inspect for any discrepancies.
mackup backup --dry-run
echo "Ensure you do not push any secrets, keys or similar."

# Execute mackup.
mackup backup

# Push the latest.
cd "$HOME/git/dotfiles"
gaa ; gmsg "Back up machine configuration" ; gp
```
