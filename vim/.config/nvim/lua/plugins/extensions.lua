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

    -- https://github.com/nvim-treesitter/playground
    { "nvim-treesitter/playground" },

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

    {
        "junegunn/fzf",
        dir = "~/.fzf",
        build = "./install --bin",
    },

    {
        "ibhagwan/fzf-lua",
        init = function()
            -- fzf.lua
            vim.keymap.set("n", "<c-f>f", "<cmd>lua require('fzf-lua').files()<CR>")
            vim.keymap.set("n", "<c-f>n", "<cmd>lua require('fzf-lua').git_files()<CR>")
            vim.keymap.set("n", "<c-f>l", "<cmd>lua require('fzf-lua').blines()<CR>")
            -- vim.keymap.set("n", "<c-f>g", "<cmd>lua require('fzf-lua').live_grep()<CR>")
            vim.keymap.set("n", "<c-f>g", "<cmd>lua require('fzf-lua').live_grep_native()<CR>")
            vim.keymap.set("n", "<c-f>h", "<cmd>lua require('fzf-lua').help_tags()<CR>")
            vim.keymap.set("n", "<c-f>c", "<cmd>lua require('fzf-lua').git_bcommits()<CR>")
            vim.keymap.set("n", "<c-f>b", "<cmd>lua require('fzf-lua').buffers()<CR>")
        end,
        opts = {
            winopts = {
                height = 0.50,
                width = 0.85,
            },
        },
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

    -- https://github.com/lewis6991/gitsigns.nvim
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                on_attach = function(bufnr)
                    local function map(mode, lhs, rhs, opts)
                        opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
                        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
                    end

                    -- Navigation
                    map("n", "]g", "&diff ? ']g' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
                    map("n", "[g", "&diff ? '[g' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

                    -- Actions
                    map("n", "<leader>hs", ":Gitsigns stage_hunk<CR>")
                    map("v", "<leader>hs", ":Gitsigns stage_hunk<CR>")
                    map("n", "<leader>hr", ":Gitsigns reset_hunk<CR>")
                    map("v", "<leader>hr", ":Gitsigns reset_hunk<CR>")
                    map("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>")
                    map("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>")
                    map("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<CR>")
                    map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>")
                    map("n", "<leader>hb", '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
                    map("n", "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<CR>")
                    map("n", "<leader>hd", "<cmd>Gitsigns diffthis<CR>")
                    map("n", "<leader>hD", '<cmd>lua require"gitsigns".diffthis("~")<CR>')
                    map("n", "<leader>td", "<cmd>Gitsigns toggle_deleted<CR>")

                    -- Text object
                    map("o", "ih", ":<C-U>Gitsigns select_hunk<CR>")
                    map("x", "ih", ":<C-U>Gitsigns select_hunk<CR>")
                end,
            })
        end,
    },

    -- https://github.com/norcalli/nvim-colorizer.lua
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    },

    { "nvim-lua/plenary.nvim" },

    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            -- https://github.com/joosepalviste/nvim-ts-context-commentstring
            { "joosepalviste/nvim-ts-context-commentstring" },
        },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash",
                    "css",
                    "diff",
                    "gitignore",
                    "hcl",
                    "help",
                    "html",
                    "http",
                    "javascript",
                    "jsdoc",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "python",
                    "rust",
                    "sql",
                    "toml",
                    "typescript",
                    "vue",
                    "yaml",
                },
                context_commentstring = { enable = true, enable_autocmd = false },
                highlight = {
                    enable = true,
                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = false,
                },
            })
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
