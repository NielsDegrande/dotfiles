-- Use syntax-based folding.
vim.opt.foldmethod = "syntax"

-- Display a column showing the fold level of each line.
vim.opt.foldcolumn = "1"

-- Remove background color for folded text.
vim.cmd("highlight Folded ctermbg=NONE")

-- Remove background color for the fold column.
vim.cmd("highlight FoldColumn ctermbg=NONE")

-- Start with all folds open (up to level 99).
vim.opt.foldlevel = 99

-- Markdown
-- Enable folding for markdown files. Both set as usage depends on the specific markdown plugin.
vim.g.markdown_folding = 1
vim.g.markdown_enable_folding = 1

-- Set the default fold level to 1 for markdown files.
vim.cmd([[ autocmd FileType markdown setlocal foldlevel=1 ]])
