-- Enable filetype detection and load filetype-specific plugins.
vim.cmd('filetype plugin on')

-- Enable filetype-specific indenting.
vim.cmd('filetype plugin indent on')

-- Set the number of spaces a tab character represents.
vim.opt.tabstop = 4

-- Number of spaces to use for an automatic indent.
vim.opt.softtabstop = 0

-- Convert tabs to spaces.
vim.opt.expandtab = true

-- Number of spaces to use for each step of (auto)indent.
vim.opt.shiftwidth = 4

-- Use 'shiftwidth' for tab commands.
vim.opt.smarttab = true

-- Indent a new line the same amount as the line just typed.
vim.opt.autoindent = true

-- Markdown
-- Set tab and indentation to 2 spaces for markdown files.
vim.cmd([[ autocmd FileType markdown setlocal tabstop=2 shiftwidth=2 ]])
