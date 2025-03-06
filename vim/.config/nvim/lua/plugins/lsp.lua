-- REFERENCES
--
--     https://github.com/hrsh7th/nvim-cmp
--     https://github.com/neovim/nvim-lspconfig
--     https://github.com/williamboman/mason-lspconfig.nvim#automatic-server-setup-advanced-feature
--


local default_capabilities = require("cmp_nvim_lsp").default_capabilities()

local default_on_attach = require("custom.utils.lsp").on_attach

local default_flags = {
    debounce_text_changes = 150,
}

return {

    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
        {
            "williamboman/mason-lspconfig.nvim",
            config = function()
                -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#customizing-how-diagnostics-are-displayed
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

                mason_lspconfig.setup_handlers({

                    -- Default handler for servers that are not explicitly defined
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            on_attach = default_on_attach,
                            capabilities = default_capabilities,
                            flags = default_flags
                        })
                    end,

                    ["lua_ls"] = function()
                        require("lspconfig").lua_ls.setup({
                            on_attach = default_on_attach,
                            capabilities = default_capabilities,
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
                            capabilities = default_capabilities,
                            flags = default_flags,
                            settings = {
                                yaml = {
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
                            capabilities = default_capabilities,
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
                })
            end,
        },
    },
}
