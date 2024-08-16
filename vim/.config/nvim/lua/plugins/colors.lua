--------------------------------------------------------------------------------
--                                   Colors                                   --
--------------------------------------------------------------------------------

return {

    -- Error: `invalid node type at position 2765 for language vim`
    -- Solution:
    -- > rm /opt/homebrew/lib/nvim/parser/vim.so

    -- -- https://github.com/tanvirtin/monokai.nvim
    -- {
    --     "tanvirtin/monokai.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     init = function()
    --         require("monokai").setup({ palette = require("monokai").pro })
    --     end,
    -- },
    --


    -- https://github.com/rebelot/kanagawa.nvim
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("kanagawa-lotus")
        end,
        enabled = true
    },

    -- https://github.com/mellow-theme/mellow.nvim
    {
        "mellow-theme/mellow.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("mellow")
        end,
        enabled = false
    },

    {
        "Verf/deepwhite.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("deepwhite")
        end,
        enabled = false
    },

    -- https://github.com/nordtheme/vim
    {
        "nordtheme/vim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("nord")
        end,
        enabled = false
    },

    {
        "nyoom-engineering/oxocarbon.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.opt.background = "dark"
            vim.cmd.colorscheme("oxocarbon")
        end,
        enabled = false,
    },

    -- https://github.com/EdenEast/nightfox.nvim
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.o.termguicolors = true
            vim.cmd.colorscheme("carbonfox")
        end,
        enabled = false,
    },

    -- https://github.com/catppuccin/nvim
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opt = {
            flavour = "macchiato"
        },
        init = function()
            require("catppuccin").setup({
                flavour = "macchiato", -- latte / frappe / mocha
                term_colors = true,
                transparent_background = false,
            })
            vim.cmd.colorscheme("catppuccin")
        end,
        enabled = false,
    },

    -- https://github.com/mcchrish/zenbones.nvim
    {
        "mcchrish/zenbones.nvim",
        dependencies = {
            "rktjmp/lush.nvim",
        },
        lazy = false,
        priority = 1000,
        config = function()
            vim.o.termguicolors = true
            vim.o.background = 'dark'
            vim.g.zenbones_compat = true
            vim.cmd.colorscheme("tokyobones")
        end,
        enabled = false,
    },

    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.o.background = "dark"
            vim.cmd.colorscheme("cyberdream")
        end,
        enabled = false,
    },

    {
        "jesseleite/nvim-noirbuddy",
        dependencies = {
            { "tjdevries/colorbuddy.nvim" },
        },
        lazy = false,
        priority = 1000,
        config = function()
            require("noirbuddy").setup({
                -- preset = "slate",
                preset = "miami-nights",
            })
        end,
        enabled = false,
    },
}
