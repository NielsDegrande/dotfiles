-- Display line numbers on the left.
vim.opt.number = true

-- Highlight the current line.
vim.opt.cursorline = true

-- Always show sign column to prevent layout shift.
vim.opt.signcolumn = "yes"

-- Hide mode text (statusline shows it).
vim.opt.showmode = false

-- Preserve indentation on wrapped lines.
vim.opt.breakindent = true

-- Keep 10 lines above/below the cursor when scrolling.
vim.opt.scrolloff = 10

-- Show invisible whitespace characters.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
