local telescope = require("telescope")

telescope.setup({
    extensions = {
        ["ui-select"] = { require("telescope.themes").get_dropdown() },
    },
})

pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "ui-select")
pcall(telescope.load_extension, "file_browser")
