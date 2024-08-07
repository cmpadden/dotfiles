--------------------------------------------------------------------------------
--                                    LSP                                     --
--------------------------------------------------------------------------------

return {
    -- https://github.com/neovim/nvim-lspconfig
    {
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

                    -- Toggle `virtual_text` on global diagnostics configuration:
                    -- vim.keymap.set("n", "<leader>td", function()
                    --     ...
                    -- end)

                    local mason_lspconfig = require("mason-lspconfig")
                    mason_lspconfig.setup({
                        ensure_installed = {
                            "bashls",
                            "eslint",
                            "html",
                            "jsonls",
                            "lua_ls",
                            "pyright",
                            "ruff",
                            "rust_analyzer",
                            "tailwindcss",
                            "tsserver",
                            "volar",
                        },
                        automatic_installation = true,
                    })
                    -- https://github.com/williamboman/mason-lspconfig.nvim#automatic-server-setup-advanced-feature
                    mason_lspconfig.setup_handlers({

                        -- The first entry (without a key) will be the default handler
                        -- and will be called for each installed server that doesn't have
                        -- a dedicated handler.
                        function(server_name)
                            local capabilities = require("cmp_nvim_lsp").default_capabilities()
                            require("lspconfig")[server_name].setup({
                                on_attach = require("custom.utils.lsp").on_attach,
                                capabilities = capabilities,
                                flags = {
                                    debounce_text_changes = 150,
                                },
                            })
                        end,
                        -- Next, you can provide a dedicated handler for specific servers.
                        -- For example, a handler override for the `lua_ls`:
                        ["lua_ls"] = function()
                            require("lspconfig").lua_ls.setup({
                                settings = {
                                    Lua = {
                                        diagnostics = {
                                            globals = { "vim", "hs" },
                                        },
                                    },
                                },
                            })
                        end,
                    })
                end,
            },
        },
    },
}
