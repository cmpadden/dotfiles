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
                            "bashls", -- Bash
                            "pyright", -- Python
                            "lua_ls", -- Lua
                            "tailwindcss", -- Tailwind
                            "tsserver", -- Typescript
                        },
                    })
                end,
            },
        },
        {
            "williamboman/mason.nvim",
            config = function()
                require("mason").setup({
                    ensure_installed = {
                        "black",
                        "flake8",
                        "isort",
                        "prettier",
                        "ruff",
                        "shellcheck",
                        "shfmt",
                        "sqlfluff",
                        "stylua",
                        "vale",
                    },
                })
            end,
        },
    },

    -- https://github.com/jose-elias-alvarez/null-ls.nvim
    {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
            local nls = require("null-ls")
            nls.setup({
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
                on_attach = function(_, bufnr)
                    vim.api.nvim_buf_set_keymap(
                        bufnr,
                        "n",
                        "<leader>f",
                        "<cmd>lua vim.lsp.buf.format { async = true }<CR>",
                        {}
                    )
                end,
            })
        end,
    },
}
