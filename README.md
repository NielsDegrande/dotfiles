# Dotfiles

Back up and restore configuration easily.
Automatically install applications and binaries.

TODO: Impact of https://github.com/lra/mackup/pull/2085?

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
echo "Validate the above list for discrepancies with the Brewfile."

ls $ZSH_CUSTOM/plugins
ls $ZSH_CUSTOM/themes
echo "Validate the above list for missing zsh plugins and themes."

# Inspect for any discrepancies.
mackup link install --dry-run
echo "Ensure you do not push any secrets, keys or similar."

# Execute mackup.
mackup link install

# Push the latest.
cd "$HOME/git/dotfiles"
git add --all ; git commit --message "Back up machine configuration" ; git push
```

## How to deal with data and other types of configuration

- `iCloud` for syncing most Apple related settings.
  TODO: Move to `macos.sh`. See `defaults read`.
- `Google Drive` and/or `OneDrive` for synchronizing data.
- `Firefox Sync` for synchronizing bookmarks and extensions. Settings with a `user.js`.

## Miscellaneous

### Firefox / Zen

#### Settings

Copy `user.js` from `manual` to the default profile.

#### KeePassXC-Browser

To connect KeePassXC with Firefox: go to KeePassXC, Settings,
Browser Integration and select Firefox.

Ensure the `Use a custom browser configuration location` under Browser Integration > Advanced
is set to: `~/Library/Application Support/Mozilla/NativeMessagingHosts`.

Additionally, you might want to export and import the extension settings (see Drive).
You do so by going to KeePassXC, Manage Extension, Preferences, and scroll to the bottom.

#### Multi-Account Containers

To change the shortcuts:

1. about:addons.
1. Select "Manage Extension Shortcuts".
1. Click the cogwheel, then "Manage Extension Shortcuts".

To load the containers: copy `containers.json`.
To edit the containers: `about:preferences#containers`.
To copy over host to container mappings: use the pen icon in the Containerise addon (Open Extension > CSV Editor).

#### Enhanced Tracking Protection

To avoid sign out loops on Microsoft web applications, disable enhanced tracking protection for these sites.

### Install Tmux Plugins

In Tmux, press `prefix` + `I` to install plugins.

### Colima

- 4 CPUs
- 8 GB RAM
- vmType: vz
- mountType: virtiofs
- rosetta: true

### nvm

Run the following and restart the shell:

```bash
nvm install latest
```

### File transfers

- `.ssh` keys.
- `.secrets` file.

### Shortcuts

- Open Archive
- VerticalMonitorLayout

### Hardcoded absolute paths

A few paths have to be absolute and hardcoded.
Search and replace if needed.

### Calendar

Set calendars to be refreshed every X minutes and not `Push` (TODO: required?).

### cron

To allow the cron job to run, you need to ensure `/usr/sbin/cron` has Full Disk Access.
System Settings > Privacy & Security > Full Disk Access > + > /usr/sbin/cron.
