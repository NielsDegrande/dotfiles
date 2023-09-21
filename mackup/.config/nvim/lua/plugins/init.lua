-- Install lazy.nvim if not already installed.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
})
end
vim.opt.rtp:prepend(lazypath)

-- Install dependencies.
require("lazy").setup({
    {"akinsho/toggleterm.nvim", version = "*", config = true},
    "folke/which-key.nvim",
    "itchyny/lightline.vim",
    {"neoclide/coc.nvim", branch = "release"},
    {"nvim-telescope/telescope-file-browser.nvim", dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }},
    {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    "Pocco81/auto-save.nvim",
    "preservim/nerdcommenter",
    "sbdchd/neoformat",
})
