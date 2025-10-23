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

                -- Override basedpyright's on_attach to use our custom keybindings.
                --
                -- When vim.lsp.config() merges configurations from multiple sources
                -- (including lsp/<name>.lua files in runtimepath), it processes:
                --
                --   1. The '*' wildcard config (defined above)
                --   2. All lsp/<name>.lua files found in runtimepath (includes both our
                --      local config and nvim-lspconfig's bundled configs)
                --   3. Any explicit vim.lsp.config(name, {...}) calls (like this one)
                --
                -- PROBLEM:
                --     nvim-lspconfig's bundled basedpyright.lua defines its own
                --     on_attach function to create a :LspPyrightOrganizeImports command. Since
                --     functions cannot be merged (only tables can), one on_attach must win.
                --     nvim-lspconfig's version overrides both our '*' config and our local
                --     lsp/basedpyright.lua file's on_attach.
                --
                -- SOLUTION:
                --
                --     Explicit vim.lsp.config() calls have the highest priority
                --     and execute last, so this override ensures our custom keybindings (like
                --     'gr' for references) are properly set up when basedpyright attaches.
                --
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
