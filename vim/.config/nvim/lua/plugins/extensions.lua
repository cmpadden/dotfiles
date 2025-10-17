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

    -- https://github.com/jpalardy/vim-slime
    {
        "jpalardy/vim-slime",
        config = function()
            vim.g.slime_target = "tmux"
            vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
            vim.g.slime_dont_ask_default = 1
            -- https://github.com/jpalardy/vim-slime#tmux
            vim.g.slime_bracketed_paste = 1
        end,
    },

    -- https://github.com/junegunn/goyo.vim
    {
        "junegunn/goyo.vim",
        config = function()
            vim.g.goyo_height = "100%"
            vim.g.goyo_width = "88"
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

    -- https://github.com/norcalli/nvim-colorizer.lua
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    },

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
            vim.g.vim_markdown_folding_level = 6          -- default to open folds
        end,
    },

    -- https://github.com/williamboman/mason.nvim
    {
        "williamboman/mason.nvim",
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonLog",
        },
        build = ":MasonUpdate",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
                ensure_installed = {
                    "codespell",
                    "prettier",
                    "ruff",
                    "shellcheck",
                    "shfmt",
                    "sqlfluff",
                    "stylua",
                    "vale",
                },
            })
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
                rust = { "rustfmt", lsp_format = "fallback" },
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

    -- https://github.com/ellisonleao/carbon-now.nvim
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

    -- https://github.com/Olical/conjure
    {
        "Olical/conjure",
        ft = { "clojure", "fennel", "python" },
        lazy = true,
        init = function()
            vim.g["conjure#log#hud#enabled"] = false
            vim.g["conjure#mapping#doc_word"] = false
        end,
    },

    -- -- https://github.com/junegunn/fzf
    -- {
    --     "junegunn/fzf",
    --     dir = "~/.fzf",
    --     build = "./install --bin",
    -- },

    -- https://github.com/ibhagwan/fzf-lua
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
            vim.keymap.set("n", "<c-f>d", "<cmd>lua require('fzf-lua').diagnostics_document()<CR>")
        end,
        opts = {
            winopts = {
                height = 0.50,
                width = 0.85,
            },
        },
    },

    -- https://github.com/lewis6991/gitsigns.nvim
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                on_attach = function(bufnr)
                    local function map(mode, lhs, rhs, opts)
                        opts =
                            vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
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
}

-- To install nightly version of Neovim on macOS:
--
--     brew install --HEAD neovim
--     brew reinstall neovim
--
if vim.version().major == 0 and vim.version().minor < 10 then
    -- https://github.com/tpope/vim-commentary (built-in as of v0.10.0)
    table.insert(obj, { "tpope/vim-commentary" })
end

return obj
