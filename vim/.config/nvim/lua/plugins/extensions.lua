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
        config = function()
            -- use pythonic folding for vim-markdown
            vim.g.vim_markdown_folding_style_pythonic = 1
        end,
    },

    -- Query models:
    --
    -- models=$(curl -s https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY")
    -- jq -r .data[].id  <(echo "$models") | sort | grep code-

    {
        "cmpadden/ChatGPT.nvim",
        -- branch = "main",
        -- dev = true,
        config = function()
            require("chatgpt").setup({
                question_sign = "Q",
                answer_sign = "A",
                yank_register = "+",
                settings_window = {
                    border = {
                        style = "single",
                        text = {
                            top = " Settings ",
                        },
                    },
                },
                chat_window = {
                    filetype = "chatgpt",
                    border = {
                        highlight = "FloatBorder",
                        style = "single",
                        text = {
                            top = " ChatGPT ",
                        },
                    },
                },
                chat_input = {
                    prompt = " > ",
                    border = {
                        highlight = "FloatBorder",
                        style = "single",
                        text = {
                            top_align = "center",
                            top = " Prompt ",
                        },
                    },
                },
                keymaps = {
                    close = { "q", "<C-c>" },
                    -- submit = "<C-Enter>",
                    submit = "<C-s>",
                    yank_last = "<C-y>",
                    yank_last_code = "<C-k>",
                    scroll_up = "<C-u>",
                    scroll_down = "<C-d>",
                    toggle_settings = "<C-o>",
                    new_session = "<C-n>",
                    cycle_windows = "<Tab>",
                    -- in the Sessions pane
                    select_session = "<Space>",
                    rename_session = "r",
                    delete_session = "d",
                },
            })
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    },

    -- https://github.com/mhartington/formatter.nvim
    {
        "mhartington/formatter.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = function()
            return {
                logging = true,
                log_level = vim.log.levels.WARN,
                filetype = {
                    python = {
                        require("formatter.filetypes.python").black,
                        require("formatter.filetypes.python").isort,
                    },
                    sh = {
                        require("formatter.filetypes.sh").shfmt,
                    },
                    sql = {
                        {
                            exe = "sqlfluff",
                            args = {
                                "fix",
                                "--force",
                                "--disable-progress-bar",
                                "--nocolor",
                                "-",
                            },
                            stdin = true,
                            ignore_exitcode = true,
                        },
                    },
                    ["*"] = {
                        require("formatter.filetypes.any").remove_trailing_whitespace
                    }
                }
            }
        end
    },
}
