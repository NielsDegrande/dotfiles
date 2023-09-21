-- Move line or visually selected block up or down (j/k).
vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', {
    noremap = true,
    silent = true
})
vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', {
    noremap = true,
    silent = true
})
vim.api.nvim_set_keymap('i', '<A-j>', '<Esc>:m .+1<CR>==gi', {
    noremap = true,
    silent = true
})
vim.api.nvim_set_keymap('i', '<A-k>', '<Esc>:m .-2<CR>==gi', {
    noremap = true,
    silent = true
})
vim.api.nvim_set_keymap('v', '<A-j>', ':m \'>+1<CR>gv=gv', {
    noremap = true,
    silent = true
})
vim.api.nvim_set_keymap('v', '<A-k>', ':m \'<-2<CR>gv=gv', {
    noremap = true,
    silent = true
})

-- Mappings with `which-key.nvim`.
local wk = require("which-key")
wk.register({
    b = {
        name = "buffer",
        s = {":ls<Cr>:b<Space>", "Switch Buffer"}
    },
    f = {
        name = "file",
        f = {"<cmd>Telescope find_files<cr>", "Find Files"},
        b = {"<cmd>Telescope file_browser<cr>", "File Browser"}
    },
    t = {
        name = "terminal",
        t = {"<cmd>ToggleTerm<cr>", "Toggle Terminal"}
    }
}, {
    prefix = "<leader>"
})
