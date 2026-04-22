-- Move line or visually selected block up or down (j/k).
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { silent = true, desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { silent = true, desc = "Move line up" })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { silent = true, desc = "Move line down" })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { silent = true, desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

-- Clear search highlights on pressing Escape.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Exit terminal mode with Esc-Esc.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation with Ctrl+h/j/k/l.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to window above" })

-- Highlight on yank.
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Telescope search keymaps.
local builtin = function(name, opts)
	return function()
		require("telescope.builtin")[name](opts)
	end
end

vim.keymap.set("n", "<leader>sh", builtin("help_tags"), { desc = "Search help" })
vim.keymap.set("n", "<leader>sk", builtin("keymaps"), { desc = "Search keymaps" })
vim.keymap.set(
	"n",
	"<leader>sf",
	builtin("find_files", { hidden = true, file_ignore_patterns = { "^%.git/" } }),
	{ desc = "Search files" }
)
vim.keymap.set("n", "<leader>ss", builtin("builtin"), { desc = "Search select Telescope" })
vim.keymap.set({ "n", "v" }, "<leader>sw", builtin("grep_string"), { desc = "Search current word" })
vim.keymap.set("n", "<leader>sg", builtin("live_grep"), { desc = "Search by grep" })
vim.keymap.set("n", "<leader>sd", builtin("diagnostics"), { desc = "Search diagnostics" })
vim.keymap.set("n", "<leader>sr", builtin("resume"), { desc = "Search resume" })
vim.keymap.set("n", "<leader>s.", builtin("oldfiles"), { desc = "Search recent files" })
vim.keymap.set("n", "<leader>sc", builtin("commands"), { desc = "Search commands" })
vim.keymap.set(
	"n",
	"<leader>s/",
	builtin("live_grep", { grep_open_files = true, prompt_title = "Live Grep in Open Files" }),
	{ desc = "Search in open files" }
)
vim.keymap.set("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Search todos" })
vim.keymap.set("n", "<leader>sb", function()
	require("telescope").extensions.file_browser.file_browser({ hidden = true, respect_gitignore = true })
end, { desc = "Search file browser" })
vim.keymap.set("n", "<leader><leader>", builtin("buffers"), { desc = "Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
	require("telescope.builtin").current_buffer_fuzzy_find(
		require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
	)
end, { desc = "Fuzzily search in current buffer" })
vim.keymap.set(
	"n",
	"<leader>sn",
	builtin("find_files", { cwd = vim.fn.stdpath("config") }),
	{ desc = "Search neovim config" }
)

-- Git keymaps.
vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<CR>", { desc = "Git blame line" })
vim.keymap.set("n", "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle inline git blame" })
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview git hunk" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff against index" })

-- Other leader keymaps.
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "File tree" })
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
vim.keymap.set("n", "<leader>dd", '"_dd', { desc = "Delete line to black hole" })
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix list" })
vim.keymap.set("n", "<leader>cp", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
	vim.notify("Copied: " .. vim.fn.expand("%"))
end, { desc = "Copy relative path" })
vim.keymap.set("n", "<leader>cP", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
	vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy absolute path" })
