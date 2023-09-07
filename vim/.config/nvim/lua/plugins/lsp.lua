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
                    local mason_lspconfig = require("mason-lspconfig")
                    mason_lspconfig.setup({
                        ensure_installed = {
                            "bashls",        -- Bash
                            "eslint",        -- Typescript
                            "html",          -- HTML
                            "jsonls",        -- JSON
                            "lua_ls",        -- Lua
                            "pyright",       -- Python
                            -- "ruff-lsp",      -- Python
                            "rust_analyzer", -- Rust
                            "tailwindcss",   -- Tailwind
                            "tsserver",      -- Typescript
                            "vuels",         -- Vue
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
                        ["lua_ls"] = function ()
                            require("lspconfig").lua_ls.setup {
                                settings = {
                                    Lua = {
                                        diagnostics = {
                                            globals = { "vim", "hs" }
                                        }
                                    }
                                }
                            }
                        end
                    })
                end,
            },
        },
    },
}
