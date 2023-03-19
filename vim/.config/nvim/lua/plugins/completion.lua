--------------------------------------------------------------------------------
--                                 Completion                                 --
--------------------------------------------------------------------------------

return {

    -- https://github.com/hrsh7th/nvim-cmp
    {
        "hrsh7th/nvim-cmp",
        -- event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer", -- https://github.com/hrsh7th/cmp-buffer
            "hrsh7th/cmp-cmdline", -- https://github.com/hrsh7th/cmp-cmdline
            "hrsh7th/cmp-emoji", -- https://github.com/hrsh7th/cmp-emoji
            "hrsh7th/cmp-nvim-lsp", -- https://github.com/hrsh7th/cmp-nvim-lsp
            "hrsh7th/cmp-path", -- https://github.com/hrsh7th/cmp-path
            "saadparwaiz1/cmp_luasnip", -- https://github.com/saadparwaiz1/cmp_luasnip
        },
        config = function()
            local cmp = require("cmp")
            local lspconfig = require("lspconfig")

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
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "emoji" },
                }),
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

            -- Mappings
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            local opts = { noremap = true, silent = true }
            vim.api.nvim_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
            vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
            vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
            vim.api.nvim_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(client, bufnr)
                -- https://github.com/LunarVim/Neovim-from-scratch/blob/7a082a3306b27d59257ce9bc826ab4dc64f69854/lua/user/lsp/handlers.lua#L88
                if client.name == "tsserver" then
                    client.resolved_capabilities.document_formatting = false
                end

                -- Enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

                -- Mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
                vim.api.nvim_buf_set_keymap(
                    bufnr,
                    "n",
                    "<space>wa",
                    "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",
                    opts
                )
                vim.api.nvim_buf_set_keymap(
                    bufnr,
                    "n",
                    "<space>wr",
                    "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>",
                    opts
                )
                vim.api.nvim_buf_set_keymap(
                    bufnr,
                    "n",
                    "<space>wl",
                    "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
                    opts
                )
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
                vim.api.nvim_buf_set_keymap(
                    bufnr,
                    "n",
                    "<space>f",
                    "<cmd>lua vim.lsp.buf.format { async = true }<CR>",
                    opts
                )
            end

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
                    on_attach = on_attach,
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

    -- snippets

    -- https://github.com/L3MON4D3/LuaSnip
    -- https://github.com/honza/vim-snippets/blob/master/snippets/
    {
        "L3MON4D3/LuaSnip",
        config = function()
            require("luasnip.loaders.from_snipmate").lazy_load()

            local ls = require("luasnip")
            local s = ls.snippet
            local t = ls.text_node
            local i = ls.insert_node
            local f = ls.function_node

            -- NOTE: this had to be a function to return context-specific
            -- comment strings, otherwise it would be initialized at startup
            --
            -- https://github.com/L3MON4D3/LuaSnip/issues/151#issuecomment-912641351
            local get_cs = function()
                return require("luasnip.util.util").buffer_comment_chars()[1]
            end

            local function create_box(opts)
                local pl = opts.padding_length or 4


                return {
                    f(function(args)
                        local cs = get_cs()
                        return cs .. string.rep(string.sub(cs, 1, 1), (pl * 2) + #args[1][1]) .. cs
                    end, { 1 }),
                    t({ "", "" }),
                    f(function()
                        local cs = get_cs()
                        return cs .. string.rep(" ", pl)
                    end),
                    i(1, "placeholder"),
                    f(function()
                        local cs = get_cs()
                        return string.rep(" ", pl) .. cs
                    end),
                    t({ "", "" }),
                    f(function(args)
                        local cs = get_cs()
                        return cs .. string.rep(string.sub(cs, 1, 1), (pl * 2) + #args[1][1]) .. cs
                    end, { 1 }),
                }
            end

            --  TODO : refactor into a single method with box width, reference:
            --  https://github.com/honza/vim-snippets/blob/c7e61b73a546c9dd0525cd158cc1613bb48e414a/pythonx/vimsnippets.py#L85

            local function bbox()

                return {
                    f(function()
                        local cs = get_cs()
                        return string.rep(string.sub(cs, 1, 1), vim.opt.textwidth:get()) 
                    end, { 1 }),
                    t({ "", "" }),
                    f(function(args)
                        local cs = get_cs()
                        local tw = vim.opt.textwidth:get()
                        local spaces = tw - (2 * #cs)
                        spaces = spaces - #args[1][1]
                        spaces = math.floor(spaces / 2)
                        return cs .. string.rep(" ", spaces)
                    end, { 1 }),
                    i(1, "placeholder"),
                    f(function(args)
                        local cs = get_cs()
                        local tw = vim.opt.textwidth:get()
                        local spaces = tw - (2 * #cs)
                        spaces = spaces - #args[1][1]
                        spaces = math.ceil(spaces / 2)
                        return string.rep(" ", spaces) .. cs
                    end, { 1 }),
                    t({ "", "" }),
                    f(function()
                        local cs = get_cs()
                        return string.rep(string.sub(cs, 1, 1), vim.opt.textwidth:get()) 
                    end, { 1 }),
                }
            end

            require("luasnip").add_snippets("all", {
                -- https://github.com/L3MON4D3/LuaSnip/wiki/Cool-Snippets#box-comment-like-ultisnips
                s({ trig = "box" }, create_box({ padding_length = 8 })),
                s({ trig = "bbox" }, bbox()),
            })

            vim.cmd([[
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>
]]           )

            vim.api.nvim_create_user_command(
                "EditSnippets",
                'lua require("luasnip.loaders").edit_snippet_files()',
                { desc = "Edit LuaSnip snippets" }
            )
        end,
    },
}
