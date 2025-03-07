-- REFERENCES
--
--     https://github.com/hrsh7th/nvim-cmp
--     https://github.com/williamboman/mason-lspconfig.nvim#automatic-server-setup-advanced-feature
--

return {
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
}
