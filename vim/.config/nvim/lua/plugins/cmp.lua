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
                    { name = "nvim_lsp", priority = 1250 },
                    { name = "buffer",   priority = 1000 },
                    { name = "luasnip",  priority = 750 },
                    { name = "path",     priority = 500 },
                    { name = "emoji",    priority = 250 },
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

            local function box(opts)
                -- NOTE: this had to be a function, otherwise `textwidth` was 0 during
                -- initialization. Still need to better understand when variables are
                -- populated.
                local function box_width()
                    return opts.box_width or vim.opt.textwidth:get()
                end

                local function padding(cs, input_text)
                    local spaces = box_width() - (2 * #cs)
                    spaces = spaces - #input_text
                    return spaces / 2
                end

                -- https://github.com/L3MON4D3/LuaSnip/issues/151#issuecomment-912641351
                local comment_string = function()
                    return require("luasnip.util.util").buffer_comment_chars()[1]
                end

                return {
                    f(function()
                        local cs = comment_string()
                        return string.rep(string.sub(cs, 1, 1), box_width())
                    end, { 1 }),
                    t({ "", "" }),
                    f(function(args)
                        local cs = comment_string()
                        return cs .. string.rep(" ", math.floor(padding(cs, args[1][1])))
                    end, { 1 }),
                    i(1, "placeholder"),
                    f(function(args)
                        local cs = comment_string()
                        return string.rep(" ", math.ceil(padding(cs, args[1][1]))) .. cs
                    end, { 1 }),
                    t({ "", "" }),
                    f(function()
                        local cs = comment_string()
                        return string.rep(string.sub(cs, 1, 1), box_width())
                    end, { 1 }),
                }
            end

            require("luasnip").add_snippets("all", {
                s({ trig = "box" }, box({ box_width = 24 })),
                s({ trig = "bbox" }, box({})),
            })

            vim.cmd([[
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>
]])

            vim.api.nvim_create_user_command(
                "EditSnippets",
                'lua require("luasnip.loaders").edit_snippet_files()',
                { desc = "Edit LuaSnip snippets" }
            )
        end,
    },

    -- https://github.com/zbirenbaum/copilot.lua
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                panel = {
                    enabled = true,
                    auto_refresh = false,
                    layout = {
                        position = "right",
                        ratio = 0.5,
                    },
                    -- USAGE: begin typing and press <c-p> to open panel. naviate
                    -- between options with `[[` and `]]` and then `<cr>` to select the
                    -- desired suggestion.
                    keymap = {
                        jump_prev = "[[",
                        jump_next = "]]",
                        accept = "<CR>",
                        refresh = "gr",
                        open = "<C-p>",
                    },
                },
                suggestion = {
                    enabled = false,
                },
            })
        end,
    },
}
