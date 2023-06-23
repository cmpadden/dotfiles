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
                    require("mason-lspconfig").setup({
                        ensure_installed = {
                            "bashls",      -- Bash
                            "pyright",     -- Python
                            "lua_ls",      -- Lua
                            "tailwindcss", -- Tailwind
                            "tsserver",    -- Typescript
                        },
                    })
                end,
            },
        },
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local servers = {
                "bashls",
                "eslint",
                "html",
                "jsonls",
                "lua_ls",
                "pyright",
                "rust_analyzer",
                "tailwindcss",
                "tsserver",
                "vuels",
            }

            for _, lsp in ipairs(servers) do
                lspconfig[lsp].setup({
                    on_attach = require("custom.utils.lsp").on_attach,
                    capabilities = capabilities,
                    flags = {
                        debounce_text_changes = 150,
                    },
                    settings = {
                        Lua = {
                            runtime = {
                                version = "LuaJIT",
                            },
                            diagnostics = {
                                globals = { "vim", "hs", "spoon" },
                            },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true), -- Make the server aware of Neovim runtime files
                                checkThirdParty = false,
                            },
                            telemetry = {
                                enable = false, -- Do not send telemetry data containing a randomized but unique identifier
                            },
                        },
                    },
                })
            end
        end,
    },

    -- https://github.com/jose-elias-alvarez/null-ls.nvim
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "mason.nvim" },
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
                    nls.builtins.completion.spell,
                    nls.builtins.diagnostics.vale,

                    -- lua
                    nls.builtins.formatting.stylua.with({ extra_args = { "--indent-type", "Spaces" } }),

                    -- javascript
                    nls.builtins.formatting.prettier,
                },
                on_attach = require("custom.utils.lsp").on_attach,
            }
        end,
    },
}
