# Hotkeys

Keyboard shortcuts on this machine: system-wide ones spread across
Karabiner-Elements, skhd/yabai, and individual app preferences, plus
terminal bindings (tmux, zsh). This file documents them in one place;
the linked configs remain the source of truth.

## Hyper key

Defined in [`mackup/.config/karabiner/karabiner.json`](mackup/.config/karabiner/karabiner.json):

| Key | Action |
| --- | --- |
| Caps Lock (tap) | Escape |
| Caps Lock (hold) | Hyper (⌘⌃⌥⇧) |

## Window management (skhd + yabai)

Defined in [`mackup/.skhdrc`](mackup/.skhdrc). Three layers share `h/j/k/l`:

| Layer | Purpose |
| --- | --- |
| hyper | Focus windows and toggles |
| ⇧⌥ | Move windows |
| ⌃⌥ (left ctrl) | Resize windows |

### Focus

| Hotkey | Action |
| --- | --- |
| hyper h/j/k/l | Focus window west / south / north / east |
| hyper 1/2/3 | Focus monitor 1 / 2 / 3 |
| hyper p / n | Focus previous / next window (stack-aware, wraps around) |

### Move

| Hotkey | Action |
| --- | --- |
| ⇧⌥ h/j/k/l | Move (warp) window west / south / north / east |
| ⇧⌥ 1/2/3 | Move window to monitor 1 / 2 / 3 and follow focus |

### Resize and layout

| Hotkey | Action |
| --- | --- |
| ⌃⌥ h/j/k/l | Resize window left / down / up / right |
| hyper 0 | Balance all windows on the space |
| hyper f | Toggle zoom-fullscreen (within the tiling grid; native fullscreen stays on fn-F) |
| hyper x | Toggle window split type (horizontal/vertical) |
| hyper t | Toggle float and center window |
| hyper b | Space layout: BSP (tiling) |
| hyper s | Space layout: stack |
| hyper r | Restart yabai |

## App hotkeys

Configured in each app's own preferences (sandboxed plists are backed up via
`scripts/mackup_copy.sh`).

| Hotkey | App | Action |
| --- | --- | --- |
| hyper v | Maccy | Open clipboard history popup |
| hyper i | Ice | Toggle hidden menu bar section |
| hyper m | MeetingBar | Join the next meeting |
| hyper e | espanso | Open search bar (set in [`espanso/config/default.yml`](mackup/Library/Application%20Support/espanso/config/default.yml)) |
| ⌃⇧ v | KeePassXC | Global Auto-Type |

espanso also expands typed triggers (currently only the stock examples, e.g.
`:date`) defined in
[`espanso/match/base.yml`](mackup/Library/Application%20Support/espanso/match/base.yml).

Within the Maccy popup (paste-by-default is enabled, so ⏎ pastes):

| Hotkey | Action |
| --- | --- |
| ⏎ | Paste selected item |
| ⌘⇧ ⏎ | Paste selected item without formatting |
| ⌥ ⏎ | Copy only (no paste) |
| ⌥ ⌫ | Delete selected history item |
| ⌥ p | Pin selected item |

## Right ⌘ layer (Karabiner)

Right ⌘ acts as a navigation and app-launcher modifier
([`karabiner.json`](mackup/.config/karabiner/karabiner.json)).

### Navigation

| Hotkey | Action |
| --- | --- |
| r⌘ h/j/k/l | Arrow keys (← ↓ ↑ →) |
| r⌘ u / i | Home / End |

### Launch apps

| Key | r⌘ | r⌘⌥ |
| --- | --- | --- |
| a | Activity Monitor | — |
| b | Zen | Safari |
| c | Visual Studio Code | Calendar |
| d | DBeaver | Dictionary |
| f | Finder | Finder → Downloads |
| m | Messages | — |
| p | KeePassXC | — |
| s | System Settings | — |
| t | Alacritty | — |
| v | Preview | UTM |

## Terminal

Bindings inside Alacritty, tmux, and zsh; nvim has its own
[cheatsheet](mackup/.config/nvim/cheatsheet.md).

### Alacritty

Launches straight into the `default` tmux session. Left ⌥ acts as Alt
(`option_as_alt = "OnlyLeft"` in
[`alacritty.toml`](mackup/.config/alacritty/alacritty.toml)), which enables
the ⌥ bindings in zsh below.

| Hotkey | Action |
| --- | --- |
| ⌃⇧ u | Hint mode: open a URL from the scrollback |
| ⌃⇧ f | Hint mode: open a file path (in VS Code at line:col when present) |
| ⌃⇧ g | Hint mode: copy a git commit hash |
| ⇧ ⏎ | Send ⎋ ↵ (insert newline without submitting, e.g. in Claude Code) |

Hints are also clickable with ⇧ + mouse.

### tmux (prefix ⌃a)

| Hotkey | Action |
| --- | --- |
| prefix f | Fuzzy-switch windows (fzf popup over names and pane directories) |
| prefix \| / - | Split pane horizontally / vertically (keeps current path) |
| prefix h | Hide current window (move to parking session) |
| prefix u | Unhide: pick a window back from parking |
| prefix . | Move current window to index N, shifting others |
| prefix ⌃z | Ignored (prevents accidentally suspending the tmux client) |
| y (copy mode) | Yank selection to the system clipboard |

Sessions auto-save every 15 minutes and restore on server start (tmux-continuum).

### zsh

| Hotkey | Action |
| --- | --- |
| Tab | fzf-tab fuzzy completion (paths, git branches, processes, options) |
| ⌃r | atuin history search; ⌃r again cycles global → host → session → directory |
| ⌃t | fzf file picker (ripgrep-backed, includes hidden files) |
| ↑ | History substring search (unchanged; atuin leaves the arrow keys alone) |
| ⌥ c | fzf directory picker: cd into the selection |
| → | Accept the inline autosuggestion (zsh-autosuggestions) |
| ⎋ | vi-mode: edit the command line with vi keys (instant, `KEYTIMEOUT=1`) |

The `searchbindkey` alias fuzzy-searches every active zsh binding.

## VS Code

Custom bindings in
[`keybindings.json`](mackup/Library/Application%20Support/Code/User/keybindings.json):

| Hotkey | Action |
| --- | --- |
| ⌃ ` | Toggle focus between terminal and editor |
| ⌃⇧ j | Toggle maximized panel |
| ⇧⌥ ] / [ | Focus next / previous terminal |
| ⌃⇧ t | Focus terminal |
| ⌃⇧ d | Focus debug REPL panel |
| ⌃⇧⌘ d | Send selection to debug REPL |
| ⌃⇧ o | Focus output panel |
| ⌃⇧ p | Focus problems panel |
| ⌥ tab | Quick-switch window |
| ⇧ ⏎ (in terminal) | Insert `\` + newline (line continuation) |

## Notes

- Hot corners are disabled in [`mackup/.macos`](mackup/.macos).
- Spotlight keeps its default ⌘ Space; no other binding uses Space.
- Zen switches tabs in most-recently-used order on ⌃ Tab
  ([`manual/user.js`](manual/user.js)).
- Not covered here: nvim (see the cheatsheet linked above).
