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
                            "bashls",      -- Bash
                            "eslint",      -- Typescript
                            "html",        -- HTML
                            "jsonls",      -- JSON
                            "lua_ls",      -- Lua
                            "pyright",     -- Python
                            "rust_analyzer",
                            "tailwindcss", -- Tailwind
                            "tsserver",    -- Typescript
                            "vuels",       -- Vue
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
                    })
                end,
            },
        },
    },

    -- https://github.com/jose-elias-alvarez/null-ls.nvim
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "williamboman/mason.nvim", "nvim-lua/plenary.nvim" },
        opts = function()
            local nls = require("null-ls")
            return {
                debug = false,
                diagnostics_format = "[#{s}] [#{c}] #{m}",
                sources = {
                    -- python
                    nls.builtins.diagnostics.ruff,
                    nls.builtins.formatting.black,
                    nls.builtins.formatting.isort,

                    -- snowflake
                    nls.builtins.diagnostics.sqlfluff.with({ extra_args = { "--dialect", "snowflake" } }),
                    nls.builtins.formatting.sqlfluff.with({ extra_args = { "--dialect", "snowflake" } }),

                    -- shell
                    nls.builtins.code_actions.shellcheck,
                    nls.builtins.diagnostics.shellcheck,
                    nls.builtins.formatting.shfmt.with({ extra_args = { "-i", "4" } }),

                    -- prose
                    -- https://github.com/hrsh7th/nvim-cmp/discussions/1286#discussioncomment-4092747
                    -- nls.builtins.completion.spell,
                    -- nls.builtins.diagnostics.vale,

                    -- lua
                    nls.builtins.formatting.stylua.with({ extra_args = { "--indent-type", "Spaces" } }),

                    -- javascript
                    nls.builtins.formatting.prettier,
                    nls.builtins.formatting.eslint,
                },
                on_attach = require("custom.utils.lsp").on_attach,
            }
        end,
    },
}
