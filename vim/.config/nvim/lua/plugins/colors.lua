--------------------------------------------------------------------------------
--                                   Colors                                   --
--------------------------------------------------------------------------------

return {

    -- -- https://github.com/folke/tokyonight.nvim
    -- {
    --     "folke/tokyonight.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     init = function()
    --         vim.cmd("colorscheme tokyonight-night")
    --     end,
    -- },

    -- -- https://github.com/folke/tokyonight.nvim
    -- {
    --     "folke/tokyonight.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     opts = { style = "night" },
    --     config = function(_, opts)
    --         local tokyonight = require("tokyonight")
    --         tokyonight.setup(opts)
    --         tokyonight.load()
    --         vim.opt.signcolumn = "yes"
    --     end,
    -- },

    -- Error: `invalid node type at position 2765 for language vim`
    -- Solution:
    -- > rm /opt/homebrew/lib/nvim/parser/vim.so

    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.cmd.colorscheme("nordfox")
            -- vim.cmd.colorscheme("terafox")
            -- vim.cmd.colorscheme("dayfox")
            -- vim.cmd.colorscheme("dawnfox")
        end,
    },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        init = function()
            -- require("catppuccin").setup({
            --     flavour = "mocha", -- latte, frappe, macchiato, mocha
            --     term_colors = true,
            --     transparent_background = false,
            --     color_overrides = {
            --         mocha = {
            --             base = "#000000",
            --         },
            --     },
            -- })
            -- vim.cmd.colorscheme("catppuccin")
        end,
    },
}
