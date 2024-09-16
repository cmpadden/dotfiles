--------------------------------------------------------------------------------
--                                 Extensions                                 --
--------------------------------------------------------------------------------

local obj = {

    -- https://github.com/tpope/vim-dadbod
    { "tpope/vim-dadbod" },

    -- https://github.com/tpope/vim-fugitive
    { "tpope/vim-fugitive" },

    -- https://github.com/tpope/vim-obsession
    { "tpope/vim-obsession" },

    -- https://github.com/tpope/vim-rhubarb
    { "tpope/vim-rhubarb" },

    -- https://github.com/tpope/vim-surround
    { "tpope/vim-surround" },

    -- https://github.com/ggandor/lightspeed.nvim
    { "ggandor/lightspeed.nvim" },

    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && yarn install",
        cmd = "MarkdownPreview",
        lazy = false,
        config = function()
            -- open the preview window after entering the markdown buffer
            vim.g.mkdp_auto_start = 0
        end,
    },

    -- https://github.com/jpalardy/vim-slime
    {
        "jpalardy/vim-slime",
        config = function()
            vim.g.slime_target = "tmux"
            vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
            vim.g.slime_dont_ask_default = 1
            vim.g.slime_bracketed_paste = 1 -- https://github.com/jpalardy/vim-slime#tmux
        end,
    },

    -- https://github.com/junegunn/goyo.vim
    {
        "junegunn/goyo.vim",
        config = function()
            vim.g.goyo_width = "120"
            vim.keymap.set("n", "<localleader>G", ":Goyo<CR>")

            vim.cmd([[
            function! s:goyo_enter()
              :Gitsigns toggle_signs
              if exists('$TMUX')
                silent !tmux set status off
              endif
            endfunction

            function! s:goyo_leave()
              :Gitsigns toggle_signs
              if exists('$TMUX')
                silent !tmux set status on
              endif
            endfunction

            autocmd! User GoyoEnter nested call <SID>goyo_enter()
            autocmd! User GoyoLeave nested call <SID>goyo_leave()
            ]])
        end,
    },

    -- https://github.com/junegunn/vim-easy-align
    {
        "junegunn/vim-easy-align",
        init = function()
            vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
            vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")
        end,
    },

    -- https://github.com/lervag/vimtex
    -- { "lervag/vimtex" },

    -- -- https://github.com/norcalli/nvim-colorizer.lua
    -- {
    --     "norcalli/nvim-colorizer.lua",
    --     config = function()
    --         require("colorizer").setup()
    --     end,
    -- },

    -- https://github.com/preservim/vim-markdown
    {
        "preservim/vim-markdown",
        dependencies = {
            "godlygeek/tabular", -- needed for FormatTable
        },
        config = function()
            vim.g.vim_markdown_folding_style_pythonic = 1 -- use pythonic folding for vim-markdown
            vim.g.vim_markdown_folding_level = 6 -- default to open folds
        end,
    },

    -- https://github.com/stevearc/conform.nvim
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true })
                end,
                mode = "",
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                ["*"] = { "codespell", "trim_whitespace" },
                javascript = { "prettier" },
                lua = { "stylua" },
                sh = { "shfmt" },
                sql = { "sqlfluff" },
                typescript = { "prettier" },
                vue = { "prettier" },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            formatters = {
                sqlfluff = {
                    prepend_args = { "--dialect", "snowflake" },
                },
            },
        },
    },

    -- Shoutout to Tim!
    {
        "ellisonleao/carbon-now.nvim",
        cmd = "CarbonNow",
        lazy = true,
        opts = {
            open_cmd = "open", -- default: xdg-open
            options = {
                drop_shadow_blur = "68px",
                drop_shadow = false,
                drop_shadow_offset_y = "20px",
                font_family = "Hack",
                font_size = "18px",
                line_height = "133%",
                line_numbers = true,
                theme = "shades-of-purple",
                titlebar = "",
                watermark = false,
                width = "680",
                window_theme = "round",
                bg = "black",
            },
        },
        keys = {
            { "<leader>cn", ":CarbonNow<CR>", mode = "v", silent = true },
        },
    },

    {
        "Olical/conjure",
        ft = { "clojure", "fennel", "python" },
        lazy = true,
        init = function()
            vim.g["conjure#log#hud#enabled"] = false
            vim.g["conjure#mapping#doc_word"] = false
        end,
    },
}

-- To install nightly version of Neovim on macOS:
--
-- brew install --HEAD neovim
-- brew reinstall neovim
--
if vim.version().major == 0 and vim.version().minor < 10 then
    -- https://github.com/tpope/vim-commentary (built-in as of v0.10.0)
    table.insert(obj, { "tpope/vim-commentary" })
end

return obj
