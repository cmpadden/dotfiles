return {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
        "saghen/blink.cmp",
        {
            "williamboman/mason-lspconfig.nvim",
            config = function()
                vim.diagnostic.config({
                    virtual_text = false,
                    underline = true,
                    update_in_insert = false,
                    severity_sort = false,
                    -- https://neovim.io/doc/user/diagnostic.html#diagnostic-signs
                    signs = {
                        text = {
                            [vim.diagnostic.severity.ERROR] = '•',
                            [vim.diagnostic.severity.WARN] = '•',
                        },
                    },
                })

                -- https://cmp.saghen.dev/installation#merging-lsp-capabilities
                local capabilities = vim.tbl_deep_extend(
                    'force',
                    vim.lsp.protocol.make_client_capabilities(),
                    require('blink.cmp').get_lsp_capabilities({}, false)
                )

                -- Configurations in `lsp/` are merged with the default configurations with the
                -- following priority:
                --
                --     1. Configuration defined for the '*' name.
                --     2. Configuration from the result of merging all tables returned by lsp/<name>.lua files in 'runtimepath' for a server of name name.
                --     3. Configurations defined anywhere else.
                --
                vim.lsp.config("*", {
                    capabilities = capabilities,
                    on_attach = require("shared").default_on_attach,
                    flags = { debounce_text_changes = 150 },
                })

                -- TODO determine why `cmd` in `lsp/ruff.lua` was not being prioritized
                vim.lsp.config("ruff", {
                    cmd = { ".venv/bin/ruff", "server" },
                })

                -- Force basedpyright to use our custom on_attach since nvim-lspconfig's
                -- bundled basedpyright.lua overrides it
                vim.lsp.config("basedpyright", {
                    on_attach = require("shared").default_on_attach,
                })

                require("mason-lspconfig").setup({
                    ensure_installed = {
                        "basedpyright",
                        "bashls",
                        "eslint",
                        "html",
                        "jsonls",
                        "lua_ls",
                        "rust_analyzer",
                        "tailwindcss",
                    },
                    automatic_installation = true,
                })
            end,
        },
    },
}
