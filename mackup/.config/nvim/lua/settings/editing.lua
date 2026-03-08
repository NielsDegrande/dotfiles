-- Set the number of spaces a tab character represents.
vim.opt.tabstop = 4

-- Convert tabs to spaces.
vim.opt.expandtab = true

-- Number of spaces to use for each step of (auto)indent.
vim.opt.shiftwidth = 4

-- Set tab and indentation to 2 spaces for markdown files.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})
