-- Display line numbers on the left.
vim.opt.number = true

-- Show cursor position (row and column) in the status line.
vim.opt.ruler = true

-- Set the status line to always be visible.
-- 0: Never display the status line.
-- 1: Only display if there are at least two windows.
-- 2: Always display the status line.
vim.opt.laststatus = 2

-- Keep 5 lines above/below the cursor when scrolling.
vim.opt.scrolloff = 5

-- Highlight matching brackets.
vim.opt.showmatch = true

-- Set the behavior of the backspace key.
-- "indent": Allow backspacing over auto-indentation.
-- "eol": Allow backspacing over line breaks (end of line).
-- "start": Allow backspacing from the start position of when you entered the current mode (e.g., from insert mode).
vim.opt.backspace = {"indent", "eol", "start"}

-- Display incomplete commands in the lower right corner.
vim.opt.showcmd = true

-- Setting background color for popup menus 
vim.api.nvim_exec([[
  highlight Pmenu ctermbg=darkgray guibg=darkgray
]], false)
