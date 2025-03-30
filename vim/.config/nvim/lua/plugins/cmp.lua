-- REFERENCES
--
--     https://github.com/saghen/blink.cmp
--     https://github.com/moyiz/blink-emoji.nvim
--     https://cmp.saghen.dev/configuration/snippets
--     https://cmp.saghen.dev/modes/cmdline.html
--     https://cmp.saghen.dev/recipes.html#border

return {
    'saghen/blink.cmp',
    dependencies = {
        "moyiz/blink-emoji.nvim",
        { 'L3MON4D3/LuaSnip', version = 'v2.*' },
    },
    version = '1.*',
    prebuilt_binaries = {
        download = true
    },
    opts = {
        keymap = {
            preset = 'default',
            ['<C-l>'] = { 'select_and_accept' }, -- default <C-y>
        },
        appearance = {
            nerd_font_variant = 'mono'
        },
        completion = {
            menu = { border = 'single' },
            documentation = { auto_show = true, window = { border = 'single' } },
        },
        cmdline = {
            keymap = {
                preset = 'cmdline',
                ['<C-l>'] = { 'select_and_accept' },
                ['<C-n>'] = { 'show_and_insert', 'select_next', 'fallback' },
            },
        },
        snippets = {
            preset = 'luasnip'
        },
        sources = {
            default = {
                'snippets',
                'lsp',
                'path',
                'emoji',
                'buffer',
            },
            providers = {
                emoji = {
                    module = "blink-emoji",
                    name = "emoji",
                    score_offset = 15,
                    opts = { insert = true },
                    -- should_show_items = function()
                    --   return vim.tbl_contains(
                    --     -- Enable emoji completion only for git commits and markdown.
                    --     -- By default, enabled for all file-types.
                    --     { "gitcommit", "markdown" },
                    --     vim.o.filetype
                    --   )
                    -- end,
                },
            },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
}
