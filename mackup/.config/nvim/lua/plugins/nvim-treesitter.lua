-- Eagerly install a base set of parsers.
require("nvim-treesitter").install({ "bash", "c", "diff", "html", "lua", "luadoc", "markdown", "markdown_inline", "query", "vim", "vimdoc", "go", "python", "typescript", "javascript", "json", "yaml", "toml" })

-- Enable treesitter-based highlighting and indentation for all filetypes.
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local buf = args.buf
        local language = vim.treesitter.language.get_lang(args.match)
        if not language then return end
        if not pcall(vim.treesitter.language.add, language) then return end
        if not pcall(vim.treesitter.start, buf, language) then return end
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

-- Enable treesitter-based folding (disabled by default, use `zi` to toggle).
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldenable = false
