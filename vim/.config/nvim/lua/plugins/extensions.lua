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
}
