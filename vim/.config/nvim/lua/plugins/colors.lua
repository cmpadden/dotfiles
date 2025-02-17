-------------------------------------------------------------------------------
--                                   Colors                                   --
--------------------------------------------------------------------------------

return {

    -- Error: `invalid node type at position 2765 for language vim`
    -- Solution:
    -- > rm /opt/homebrew/lib/nvim/parser/vim.so

    -- https://github.com/EdenEast/nightfox.nvim
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        -- config = function()
        --     vim.o.termguicolors = true
        --     require("nightfox").setup {
        --         style = "terafox"
        --     }
        -- end,
        init = function()
            vim.o.termguicolors = true
            vim.cmd.colorscheme("terafox")
            -- vim.cmd.colorscheme("dayfox")
        end,
        enabled = false,
    },

    -- https://github.com/catppuccin/nvim
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opt = {
            flavour = "latte",
        },
        init = function()
            -- require("catppuccin").setup({
            --     flavour = "macchiato", -- latte / frappe / mocha
            --     term_colors = true,
            --     transparent_background = false,
            -- })
            vim.cmd.colorscheme("catppuccin")
        end,
        enabled = true,
    },

    -- https://github.com/tanvirtin/monokai.nvim
    {
        "tanvirtin/monokai.nvim",
        lazy = false,
        init = function()
            local palette = require("monokai").pro
            palette.base2 = '#000000'
            require("monokai").setup({ palette = palette, italics = false })
        end,
        enabled = false,
    },

    -- https://github.com/jesseleite/nvim-noirbuddy
    {
        "jesseleite/nvim-noirbuddy",
        dependencies = {
            { "tjdevries/colorbuddy.nvim" },
        },
        lazy = false,
        priority = 1000,
        config = function()
            require("noirbuddy").setup({
                preset = "slate",
                colors = {
                    background = "#18181A",
                },
            })
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
            vim.o.background = "dark"
            -- vim.g.rosebones_darkness = "stark"
            vim.cmd.colorscheme("zenbones")
        end,
        enabled = false,
    },

    -- https://github.com/cocopon/iceberg.vim
    -- https://speakerdeck.com/cocopon/creating-your-lovely-color-scheme
    {
        "cocopon/iceberg.vim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("iceberg")
        end,
        enabled = false,
    },

    -- https://github.com/rebelot/kanagawa.nvim
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("kanagawa-dragon")
        end,
        enabled = false,
    },

    -- https://github.com/mellow-theme/mellow.nvim
    {
        "mellow-theme/mellow.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            require('kanagawa').setup({
                transparent = true,
                colors = {
                    theme = {
                        ui = {
                            bg = "#000000",
                        }
                    }
                }
            })
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("mellow")
        end,
        enabled = false,
    },

    -- https://github.com/Verf/deepwhite.nvim
    {
        "Verf/deepwhite.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("deepwhite")
        end,
        enabled = false,
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
        enabled = false,
    },

    -- https://github.com/nyoom-engineering/oxocarbon.nvim
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

    -- https://github.com/scottmckendry/cyberdream.nvim
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
}
