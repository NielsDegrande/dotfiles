-- Configure diagnostic display.
vim.diagnostic.config({
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
    underline = { severity = { min = vim.diagnostic.severity.ERROR } },
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    } or {},
    virtual_text = { source = "if_many" },
    jump = { float = true },
})

-- LSP servers to install and configure.
-- Add servers here as needed, e.g. pyright, ts_ls, gopls, lua_ls.
local servers = {
    gopls = {
        settings = {
            gopls = {
                directoryFilters = { "-node_modules", "-vendor", "-.git" },
            },
        },
    },
    lua_ls = {
        on_init = function(client)
            if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if path ~= vim.fn.stdpath("config")
                    and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) then
                    return
                end
            end
            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
                workspace = {
                    checkThirdParty = false,
                    library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
                        "${3rd}/luv/library",
                        "${3rd}/busted/library",
                    }),
                },
            })
        end,
        settings = { Lua = {} },
    },
    pyright = {},
    ts_ls = {},
}

-- Ensure servers and tools are installed (using Mason package names).
local ensure_installed = {
    "gopls",
    "lua-language-server",
    "pyright",
    "typescript-language-server",
    "gofumpt",
    "golangci-lint",
    "markdownlint",
    "oxfmt",
    "oxlint",
    "ruff",
    "stylua",
}
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

-- Configure and enable LSP servers using the native Neovim API.
for name, config in pairs(servers) do
    config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
    vim.lsp.config(name, config)
    vim.lsp.enable(name)
end

-- LSP keybindings (activate when an LSP attaches to a buffer).
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("grd", require("telescope.builtin").lsp_definitions, "Goto definition")
        map("grr", require("telescope.builtin").lsp_references, "Goto references")
        map("gri", require("telescope.builtin").lsp_implementations, "Goto implementation")
        map("grt", require("telescope.builtin").lsp_type_definitions, "Goto type definition")
        map("gO", require("telescope.builtin").lsp_document_symbols, "Document symbols")
        map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace symbols")
        map("grn", vim.lsp.buf.rename, "Rename")
        map("gra", vim.lsp.buf.code_action, "Code action", { "n", "x" })
        map("grD", vim.lsp.buf.declaration, "Goto declaration")
        map("<leader>ld", vim.diagnostic.open_float, "Line diagnostics")

        -- Toggle inlay hints (if supported by the LSP server).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method("textDocument/inlayHint", event.buf) then
            map("<leader>th", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Toggle inlay hints")
        end

        -- Highlight references of the word under cursor on CursorHold.
        if client and client:supports_method("textDocument/documentHighlight", event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
                end,
            })
        end
    end,
})
