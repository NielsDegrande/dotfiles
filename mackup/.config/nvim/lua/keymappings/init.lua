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

-- coc.nvim related keymappings.
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

local keyset = vim.keymap.set
local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
keyset("i", "<Tab>", [[pumvisible() ? coc#pum#confirm() : v:lua.check_back_space() ? "\<Tab>" : coc#refresh()]], opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Mappings with `which-key.nvim`.
local wk = require("which-key")
wk.add(
    {
        { "<leader>b", group = "buffer" },
        { "<leader>bs", ":ls<Cr>:b<Space>", desc = "Switch Buffer" },
        { "<leader>f", group = "file" },
        { "<leader>fb", "<cmd>Telescope file_browser<cr>", desc = "File Browser" },
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        { "<leader>t", group = "terminal" },
        { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
    }
)
