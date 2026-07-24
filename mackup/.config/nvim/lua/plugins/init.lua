-- Install lazy.nvim if not already installed.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Install dependencies.
require("lazy").setup({
    {"akinsho/toggleterm.nvim", version = "*", config = true},
    {"folke/which-key.nvim", event = "VimEnter", opts = {
        delay = 0,
        icons = { mappings = vim.g.have_nerd_font },
        spec = {
            { "<leader>s", group = "search" },
            { "<leader>d", group = "delete" },
            { "<leader>t", group = "toggle" },
            { "gr", group = "LSP actions" },
        },
    }},
    {"j-hui/fidget.nvim", opts = {}},
    {"folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {}},
    {"lewis6991/gitsigns.nvim", opts = { current_line_blame = true }},
    {"nmac427/guess-indent.nvim", opts = {}},
    {"nvim-mini/mini.nvim", version = false, config = function()
        require("mini.ai").setup({ n_lines = 500 })
        require("mini.surround").setup()
        local statusline = require("mini.statusline")
        statusline.setup({ use_icons = vim.g.have_nerd_font })
        statusline.section_location = function() return "%2l:%-2v" end
    end},
    {"m4xshen/hardtime.nvim", lazy = false, dependencies = { "MunifTanjim/nui.nvim" }, opts = { restriction_mode = "hint" },},
    {"nvim-neo-tree/neo-tree.nvim", branch = "v3.x", dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" }, opts = {
        filesystem = {
            filtered_items = { visible = true },
            follow_current_file = { enabled = true },
        },
    }},
    "navarasu/onedark.nvim",
    {"neovim/nvim-lspconfig", dependencies = {
        {"mason-org/mason.nvim", opts = {}},
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    }},
    {"saghen/blink.cmp", version = "1.*", opts = {
        keymap = { preset = "enter" },
        appearance = { nerd_font_variant = "mono" },
        sources = { default = { "lsp", "path", "snippets", "buffer" } },
        signature = { enabled = true },
        fuzzy = { implementation = "lua" },
    }},
    {"nvim-telescope/telescope-file-browser.nvim", dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }},
    {"nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end, dependencies = { "nvim-telescope/telescope.nvim" }},
    {"nvim-telescope/telescope-ui-select.nvim", dependencies = { "nvim-telescope/telescope.nvim" }},
    {"nvim-treesitter/nvim-treesitter", lazy = false, branch = "main", build = ":TSUpdate"},
    {"okuuva/auto-save.nvim", opts = {}},
    {"stevearc/conform.nvim", event = { "BufWritePre" }, cmd = { "ConformInfo" },
    keys = {
        { "<leader>f", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, mode = "", desc = "Format buffer" },
    },
    opts = {
        notify_on_error = false,
        format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
        formatters_by_ft = {
            go = { "gofumpt" },
            javascript = { "oxfmt" },
            typescript = { "oxfmt" },
            typescriptreact = { "oxfmt" },
            javascriptreact = { "oxfmt" },
            markdown = { "markdownlint" },
            lua = { "stylua" },
            python = { "ruff_format" },
        },
    }},
    {"mfussenegger/nvim-lint", config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
            go = { "golangcilint" },
            javascript = { "oxlint" },
            typescript = { "oxlint" },
            typescriptreact = { "oxlint" },
            javascriptreact = { "oxlint" },
            markdown = { "markdownlint" },
            python = { "ruff" },
        }
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
            callback = function() lint.try_lint() end,
        })
    end},
}, {
    ui = {
        icons = vim.g.have_nerd_font and {} or {
            cmd = "⌘",
            config = "🛠",
            event = "📅",
            ft = "📂",
            init = "⚙",
            keys = "🗝",
            plugin = "🔌",
            runtime = "💻",
            require = "🌙",
            source = "📄",
            start = "🚀",
            task = "📌",
            lazy = "💤 ",
        },
    },
})
