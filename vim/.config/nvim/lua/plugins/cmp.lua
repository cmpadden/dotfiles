-- REFERENCES
--
--     https://github.com/saghen/blink.cmp
--     https://github.com/moyiz/blink-emoji.nvim
--     https://cmp.saghen.dev/configuration/snippets
--     https://cmp.saghen.dev/modes/cmdline.html
--     https://cmp.saghen.dev/recipes.html#border

local M = {}

function M.setup()
    require("blink.cmp").setup({
        keymap = {
            preset = "default",
            ["<C-l>"] = { "select_and_accept" }, -- default <C-y>
        },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            menu = { border = "single" },
            documentation = { auto_show = true, window = { border = "single" } },
        },
        cmdline = {
            keymap = {
                preset = "cmdline",
                ["<C-l>"] = { "select_and_accept" },
                ["<C-n>"] = { "show_and_insert", "select_next", "fallback" },
            },
        },
        snippets = {
            preset = "default",
        },
        sources = {
            default = {
                "snippets",
                "lsp",
                "path",
                "emoji",
                "buffer",
                "dynamic_snippets",
            },
            providers = {
                dynamic_snippets = {
                    name = "Dynamic snippets",
                    module = "user.dynamic_snippets",
                    score_offset = 15,
                },
                snippets = {
                    opts = {
                        extended_filetypes = {
                            bash = { "sh" },
                        },
                    },
                },
                emoji = {
                    module = "blink-emoji",
                    name = "emoji",
                    score_offset = 15,
                    opts = { insert = true },
                },
            },
        },
        fuzzy = {
            implementation = "prefer_rust_with_warning",
            prebuilt_binaries = { download = true },
        },
    })
end

return M
