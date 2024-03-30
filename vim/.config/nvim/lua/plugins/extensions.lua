--------------------------------------------------------------------------------
--                                 Extensions                                 --
--------------------------------------------------------------------------------

return {

    -- https://github.com/tpope/vim-commentary
    { "tpope/vim-commentary" },

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
            vim.g.goyo_height = "100%"
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

    -- https://github.com/norcalli/nvim-colorizer.lua
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    },

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

    -- https://github.com/mhartington/formatter.nvim
    {
        "mhartington/formatter.nvim",
        event = { "BufReadPre", "BufNewFile" },
        init = function()
            vim.keymap.set("n", "<leader>f", "<cmd>FormatWrite<cr>")
        end,
        opts = function()
            return {
                logging = true,
                log_level = vim.log.levels.WARN,
                filetype = {
                    python = {
                        require("formatter.filetypes.python").ruff,
                        -- require("formatter.filetypes.python").isort,
                    },
                    sh = {
                        require("formatter.filetypes.sh").shfmt,
                    },
                    sql = {
                        {
                            exe = "sqlfluff",
                            args = {
                                "format",
                                "--disable-progress-bar",
                                "--nocolor",
                                "--dialect snowflake",
                                "-",
                            },
                            stdin = true,
                            ignore_exitcode = true,
                        },
                    },
                    vue = {
                        require("formatter.filetypes.vue").prettier,
                    },
                    lua = {
                        require("formatter.filetypes.lua").stylua,
                    },
                    ["*"] = {
                        require("formatter.filetypes.any").remove_trailing_whitespace,
                    },
                },
            }
        end,
    },

    -- Shoutout to Tim!
    {
        "ellisonleao/carbon-now.nvim",
        cmd = "CarbonNow",
        lazy = true,
        opts = {
            open_cmd = "open", -- default: xdg-open
            options = {
                bg = "#21463D",
                drop_shadow_blur = "68px",
                drop_shadow = false,
                drop_shadow_offset_y = "20px",
                font_family = "Hack",
                font_size = "18px",
                line_height = "133%",
                line_numbers = true,
                theme = "nord",
                titlebar = "",
                watermark = false,
                width = "680",
                window_theme = "round",
            },
        },
        keys = {
            { "<leader>cn", ":CarbonNow<CR>", mode = "v", silent = true },
        },
    },
}
