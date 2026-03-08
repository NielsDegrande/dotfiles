-- Set leader key to space.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal.
vim.g.have_nerd_font = true

-- Disable startup message.
vim.opt.shortmess:append("I")

-- Faster CursorHold events (used by LSP document highlight).
vim.opt.updatetime = 250

-- Faster which-key popup.
vim.opt.timeoutlen = 300

-- Live preview of substitutions.
vim.opt.inccommand = "split"

-- Show dialog instead of error when quitting with unsaved changes.
vim.opt.confirm = true

-- Sync clipboard between OS and Neovim (scheduled for faster startup).
vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)

-- Enable persistent undo (stored in ~/.local/state/nvim/undo).
vim.opt.undofile = true

-- Set command-line completion behavior to first list the longest common substring, then list all matches.
vim.opt.wildmode = { "longest", "list" }

-- When creating vertical splits, place the new window to the right of the current one.
vim.opt.splitright = true
-- When creating horizontal splits, place the new window below the current one.
vim.opt.splitbelow = true

-- Jump to the last position when reopening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            vim.api.nvim_win_set_cursor(0, mark)
        end
    end,
})
