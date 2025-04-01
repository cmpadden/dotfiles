-- REFERENCES
--
--     https://github.com/neovim/nvim-lspconfig
--     https://github.com/williamboman/mason-lspconfig.nvim#automatic-server-setup-advanced-feature
--     https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#customizing-how-diagnostics-are-displayed
--


-- `on_attach` to map keys after language server attaches to the current buffer
-- See `:help vim.lsp.*`
-- See `:help vim.diagnostic.*`
local default_on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true }

    -- Avoid using formatting capability for `tsserver`, and instead use `eslint` or
    -- `prettier`.
    if client.name == "tsserver" then
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    end

    -- Global Bindings - Diagnostics

    vim.keymap.set("n", "<space>d", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

    -- Buffer Bindings

    local opts_buffer = { noremap = true, silent = true, buffer = bufnr }

    if client.supports_method("textDocument/declaration") then
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts_buffer)
    end

    if client.supports_method("textDocument/definition") then
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts_buffer)
    end

    if client.supports_method("textDocument/hover") then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_buffer)
    end

    if client.supports_method("textDocument/implementation") then
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts_buffer)
    end

    if client.supports_method("textDocument/signatureHelp") then
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts_buffer)
    end

    if client.supports_method("textDocument/typeDefinition") then
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts_buffer)
    end

    if client.supports_method("textDocument/rename") then
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts_buffer)
    end

    if client.supports_method("textDocument/codeAction") then
        vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts_buffer)
    end

    if client.supports_method("textDocument/references") then
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts_buffer)
    end

    if client.supports_method("textDocument/formatting") then
        vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format({ async = true })
        end, opts_buffer)
    end

    -- if client.supports_method("textDocument/workspaceEdit") then
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts_buffer)

    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts_buffer)

    vim.keymap.set("n", "<space>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts_buffer)
end


return {

    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
        'saghen/blink.cmp',
        {
            "williamboman/mason-lspconfig.nvim",
            config = function()
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = true,
                    underline = true,
                    update_in_insert = false,
                    severity_sort = false,
                })

                local mason_lspconfig = require("mason-lspconfig")
                mason_lspconfig.setup({
                    ensure_installed = {
                        "basedpyright",
                        "bashls",
                        "eslint",
                        "html",
                        "jsonls",
                        "lua_ls",
                        "ruff",
                        "rust_analyzer",
                        "tailwindcss",
                        "volar",
                    },
                    automatic_installation = true,
                })

                -- https://cmp.saghen.dev/installation.html#lsp-capabilities
                -- https://github.com/neovim/nvim-lspconfig/issues/3494
                local blink_capabilities = require('blink.cmp').get_lsp_capabilities()

                local default_flags = { debounce_text_changes = 150 }

                mason_lspconfig.setup_handlers({

                    -- Default handler for servers that are not explicitly defined
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            on_attach = default_on_attach,
                            capabilities = blink_capabilities,
                            flags = default_flags
                        })
                    end,

                    ["lua_ls"] = function()
                        require("lspconfig").lua_ls.setup({
                            on_attach = default_on_attach,
                            capabilities = blink_capabilities,
                            flags = default_flags,
                            settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { "vim", "hs" },
                                    },
                                },
                            },
                        })
                    end,

                    ["yamlls"] = function()
                        require("lspconfig").yamlls.setup({
                            on_attach = default_on_attach,
                            capabilities = blink_capabilities,
                            flags = default_flags,
                            settings = {
                                yaml = {
                                    -- TODO - dynamically check if schemas are present
                                    schemas = {
                                        [".vscode/schema.json"] = "**/*.y*ml",
                                    },
                                },
                            },
                        })
                    end,

                    ["basedpyright"] = function()
                        require("lspconfig").basedpyright.setup({
                            on_attach = default_on_attach,
                            capabilities = blink_capabilities,
                            flags = default_flags,
                            settings = {
                                basedpyright = {
                                    analysis = {
                                        typeCheckingMode = "basic",
                                    },
                                },
                            },
                        })
                    end,

                    ["ruff"] = function()
                        require("lspconfig").ruff.setup({
                            on_attach = default_on_attach,
                            capabilities = blink_capabilities,
                            flags = default_flags,
                            -- TODO - detect virtual environment programmatically
                            cmd = { ".venv/bin/ruff", "server" }
                        })
                    end,
                })
            end,
        },
    },
}
