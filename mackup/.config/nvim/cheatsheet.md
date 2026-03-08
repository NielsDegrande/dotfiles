# Neovim Cheatsheet

Leader key: `Space`

## General

| Key | Description |
|-----|-------------|
| `<leader>w` | Save file |
| `<leader>e` | Toggle file tree (Neo-tree) |
| `<Esc>` | Clear search highlights |
| `<leader>q` | Diagnostic quickfix list |
| `<leader>f` | Format buffer |

## Moving Lines

| Key | Mode | Description |
|-----|------|-------------|
| `Alt+j` | Normal / Insert / Visual | Move line(s) down |
| `Alt+k` | Normal / Insert / Visual | Move line(s) up |

## Search (Telescope)

| Key | Description |
|-----|-------------|
| `<leader>sf` | Search files |
| `<leader>sg` | Search by grep |
| `<leader>sw` | Search current word |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |
| `<leader>sc` | Search commands |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Search resume (reopen last search) |
| `<leader>s.` | Search recent files |
| `<leader>ss` | Search select Telescope (pick a picker) |
| `<leader>s/` | Search in open files |
| `<leader>sn` | Search neovim config files |
| `<leader>st` | Search todo comments |
| `<leader>sb` | Search file browser |
| `<leader><leader>` | Find existing buffers |
| `<leader>/` | Fuzzily search in current buffer |

## Delete

| Key | Description |
|-----|-------------|
| `<leader>dd` | Delete line to black hole register |

## Terminal

| Key | Description |
|-----|-------------|
| `<leader>tt` | Toggle terminal |
| `<Esc><Esc>` | Exit terminal mode |

## Commenting (built-in)

| Key | Description |
|-----|-------------|
| `gcc` | Toggle comment on current line |
| `gc` (visual) | Toggle comment on selection |

## Surround (mini.surround)

Operators: `sa` add, `sd` delete, `sr` replace, `sf`/`sF` find right/left, `sh` highlight.
Append `n` for next or `l` for previous (e.g., `sdn'` deletes next quotes).

| Key | Description |
|-----|-------------|
| `sa{motion}{char}` | Add surrounding (e.g., `saiw)` surrounds word with parens) |
| `sd{char}` | Delete surrounding (e.g., `sd'` deletes quotes) |
| `sr{old}{new}` | Replace surrounding (e.g., `sr)"` replaces parens with quotes) |
| `sf{char}` | Find next surrounding to the right |
| `sh{char}` | Highlight surrounding |

## Textobjects (mini.ai)

Use `i` (inside) or `a` (around) with any operator (`d`, `c`, `y`, `v`).
Append `n` for next or `l` for last (e.g., `cin)` changes inside next parens).

| Key | Description |
|-----|-------------|
| `va)` | Visually select around parens |
| `ci'` | Change inside quotes |
| `din)` | Delete inside next parens |
| `yil'` | Yank inside last quotes |

## LSP

| Key | Description |
|-----|-------------|
| `grd` | Goto definition (Telescope) |
| `grr` | Goto references (Telescope) |
| `gri` | Goto implementation (Telescope) |
| `grt` | Goto type definition (Telescope) |
| `grD` | Goto declaration |
| `gO` | Document symbols (Telescope) |
| `gW` | Workspace symbols (Telescope) |
| `grn` | Rename |
| `gra` | Code action (normal + visual) |
| `K` | Hover documentation (built-in) |
| `<leader>ld` | Line diagnostics (floating window) |
| `<leader>th` | Toggle inlay hints |
| `[d` / `]d` | Previous / next diagnostic (built-in) |

## Folding

| Key | Description |
|-----|-------------|
| `zi` | Toggle folding on/off (disabled by default) |
| `za` | Toggle fold under cursor |
| `zR` | Open all folds |
| `zM` | Close all folds |

## Neo-tree

| Key | Description |
|-----|-------------|
| `<leader>e` | Toggle file tree |
| `Enter` | Open file |
| `P` | Preview (open without leaving tree) |
| `s` | Open in vertical split |
| `S` | Open in horizontal split |
| `t` | Open in new tab |
| `H` | Toggle hidden files |
| `R` | Refresh tree |
| `a` | Add file/directory |
| `d` | Delete |
| `r` | Rename |
| `c` | Copy |
| `m` | Move |
| `q` | Close tree |

## Window Navigation

| Key | Description |
|-----|-------------|
| `Ctrl+h` | Move to left window |
| `Ctrl+l` | Move to right window |
| `Ctrl+j` | Move to window below |
| `Ctrl+k` | Move to window above |
| `Ctrl+w w` | Cycle between windows |

## Completion (blink.cmp, enter preset)

| Key | Description |
|-----|-------------|
| `Ctrl+n` | Next item |
| `Ctrl+p` | Previous item |
| `Enter` | Accept completion |
| `Ctrl+Space` | Show completion menu |
| `Ctrl+e` | Hide completion menu |
| `Ctrl+k` | Toggle signature help |
| `Tab` / `Shift+Tab` | Navigate snippet fields |

## Commands

| Command | Description |
|---------|-------------|
| `:Mason` | Open Mason package manager |
| `:Lazy` | Open Lazy plugin manager |
| `:ConformInfo` | Show formatter info for current buffer |
| `:TodoTelescope` | Search TODO/FIXME comments |
| `:Neotree toggle` | Toggle file tree |
| `:ToggleTerm` | Toggle terminal |

## Managing Plugins and Tools

### Adding a new plugin

Edit `lua/plugins/init.lua` and add to the `lazy.setup()` list:

```lua
{"author/plugin-name.nvim", opts = {}},
```

Restart nvim and Lazy will auto-install it. Or run `:Lazy sync`.

### Adding a new LSP server

Edit `lua/plugins/lsp.lua`:

1. Add to the `servers` table (using lspconfig names):

```lua
local servers = {
    gopls = {},
    lua_ls = { ... },
    pyright = {},
    ts_ls = {},
    -- Add new servers here, e.g.:
    -- rust_analyzer = {},
    -- clangd = {},
}
```

2. Add the **Mason package name** to the `ensure_installed` list (Mason names differ from lspconfig names, e.g. `lua_ls` → `lua-language-server`, `ts_ls` → `typescript-language-server`):

```lua
local ensure_installed = {
    ...
    "rust-analyzer",  -- Mason package name for rust_analyzer
}
```

Restart nvim and Mason will auto-install it. Run `:Mason` to find correct package names.

### Adding a new formatter or linter

1. Add the Mason package name to the `ensure_installed` list in `lua/plugins/lsp.lua`:

```lua
local ensure_installed = {
    ...
    "golangci-lint",
    "markdownlint",
    "stylua",
    -- Add new tools here
}
```

2. Configure conform.nvim (formatters) in `lua/plugins/init.lua` under the `conform.nvim` entry.

### Useful management commands

| Command | Description |
|---------|-------------|
| `:Lazy` | Manage plugins (install, update, clean) |
| `:Lazy sync` | Install missing + update all plugins |
| `:Lazy health` | Check plugin health |
| `:Mason` | Manage LSP servers, formatters, linters |
| `:MasonInstall <name>` | Install a specific tool |
| `:MasonUninstall <name>` | Remove a tool |
| `:LspInfo` | Show active LSP clients for current buffer |
| `:checkhealth` | Run Neovim health checks |
