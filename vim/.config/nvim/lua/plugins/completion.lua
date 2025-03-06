--------------------------------------------------------------------------------
--                                 Completion                                 --
--------------------------------------------------------------------------------

return {

    -- https://github.com/hrsh7th/nvim-cmp
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer",       -- https://github.com/hrsh7th/cmp-buffer
            "hrsh7th/cmp-cmdline",      -- https://github.com/hrsh7th/cmp-cmdline
            "hrsh7th/cmp-emoji",        -- https://github.com/hrsh7th/cmp-emoji
            "hrsh7th/cmp-nvim-lsp",     -- https://github.com/hrsh7th/cmp-nvim-lsp
            "hrsh7th/cmp-path",         -- https://github.com/hrsh7th/cmp-path
            "saadparwaiz1/cmp_luasnip", -- https://github.com/saadparwaiz1/cmp_luasnip
        },
        config = function()
            local cmp = require("cmp")

            -- custom border styles of completions
            local border_opts = {
                border = "single",
                winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
            }

            cmp.setup({
                snippet = {
                    expand = function(args)
                        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                        require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                mapping = {
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-l>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
                    ["<C-e>"] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    }),
                },
                formatting = {
                    format = function(entry, vim_item)
                        -- https://www.youtube.com/watch?v=8zENSGqOk8w
                        local source = entry.source.name
                        vim_item.menu = "[" .. source .. "]"
                        return vim_item
                    end,
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 500 },
                    { name = "luasnip",  priority = 400 },
                    { name = "path",     priority = 300 },
                    { name = "emoji",    priority = 200 },
                    { name = "buffer",   priority = 100 },
                }),
                window = {
                    completion = cmp.config.window.bordered(border_opts),
                    documentation = cmp.config.window.bordered(border_opts),
                },
            })

            -- Set configuration for specific filetype.
            cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources({
                    { name = "cmp_git" }, -- You can specify the `cmp_git` source if you have installed it.
                }, {
                    { name = "buffer" },
                }),
            })

            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
            })
        end,
    },

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

                    local base_default_capabilities =
                        require("cmp_nvim_lsp").default_capabilities()

                    local base_on_attach = require("custom.utils.lsp").on_attach

                    -- https://github.com/williamboman/mason-lspconfig.nvim#automatic-server-setup-advanced-feature
                    mason_lspconfig.setup_handlers({

                        -- Default handler that is called for each server that is not explicitly
                        -- defined
                        function(server_name)
                            require("lspconfig")[server_name].setup({
                                on_attach = base_on_attach,
                                capabilities = base_default_capabilities,
                                flags = {
                                    debounce_text_changes = 150,
                                },
                            })
                        end,

                        ["lua_ls"] = function()
                            require("lspconfig").lua_ls.setup({
                                on_attach = base_on_attach,
                                capabilities = base_default_capabilities,
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
                                on_attach = base_on_attach,
                                capabilities = base_default_capabilities,
                                flags = {
                                    debounce_text_changes = 150,
                                },
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
                                on_attach = base_on_attach,
                                capabilities = base_default_capabilities,
                                flags = {
                                    debounce_text_changes = 150,
                                },
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
    },
}
