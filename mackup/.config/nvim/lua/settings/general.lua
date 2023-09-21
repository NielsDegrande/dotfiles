-- Disable startup message.
vim.opt.shortmess:append("I")

-- Optimize for fast terminal connections (reduces the delay for drawing).
vim.opt.ttyfast = true

-- Use the system clipboard for all yank, delete, change, and put operations.
vim.opt.clipboard = "unnamedplus"

-- Manage undo history.
-- Enable persistent undo.
vim.opt.undofile = true
-- Set directory for undo files.
local undo_dir = vim.fn.stdpath("config") .. "/undo"
vim.opt.undodir = undo_dir

-- Set command-line completion behavior to first list the longest common substring, then list all matches.
vim.opt.wildmode = {"longest", "list"}

-- When creating vertical splits, place the new window to the right of the current one.
vim.opt.splitright = true
-- When creating horizontal splits, place the new window below the current one.
vim.opt.splitbelow = true

-- Jump to the last position when reopening a file.
if vim.fn.has("autocmd") == 1 then
    vim.api.nvim_exec([[
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  ]], false)
end
