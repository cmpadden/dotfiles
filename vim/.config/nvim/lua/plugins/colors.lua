--------------------------------------------------------------------------------
--                                   Colors                                   --
--------------------------------------------------------------------------------

return {

    -- Error: `invalid node type at position 2765 for language vim`
    -- Solution:
    -- > rm /opt/homebrew/lib/nvim/parser/vim.so

    -- https://github.com/tanvirtin/monokai.nvim
    {
        "tanvirtin/monokai.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            require("monokai").setup({ palette = require("monokai").pro })
        end,
    },

    -- -- https://github.com/EdenEast/nightfox.nvim
    -- {
    --     "EdenEast/nightfox.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     init = function()
    --         vim.o.termguicolors = true
    --         vim.cmd.colorscheme("carbonfox")
    --     end,
    -- },

    -- -- https://github.com/catppuccin/nvim
    -- {
    --     "catppuccin/nvim",
    --     name = "catppuccin",
    --     priority = 1000,
    --     opt = {
    --         flavour = "macchiato"
    --     }
    --     init = function()
    --         require("catppuccin").setup({
    --             flavour = "macchiato", -- latte / frappe / mocha
    --             term_colors = true,
    --             transparent_background = false,
    --         })
    --         vim.cmd.colorscheme("catppuccin")
    --     end,
    -- },

    -- -- https://github.com/mcchrish/zenbones.nvim
    -- {
    --     "mcchrish/zenbones.nvim",
    --     dependencies = {
    --         "rktjmp/lush.nvim",
    --     },
    --     lazy = false,
    --     priority = 1000,
    --     -- config = function()
    --     --     vim.o.termguicolors = true
    --     --     vim.o.background = 'dark'
    --     --     vim.g.zenbones_compat = true
    --     --     vim.cmd.colorscheme("tokyobones")
    --     -- end,
    -- },

    -- {
    --     "scottmckendry/cyberdream.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         vim.o.background = "dark"
    --         vim.cmd.colorscheme("cyberdream")
    --     end,
    -- },

    --     {
    --         "jesseleite/nvim-noirbuddy",
    --         dependencies = {
    --             { "tjdevries/colorbuddy.nvim" },
    --         },
    --         lazy = false,
    --         priority = 1000,
    --         config = function()
    --             require("noirbuddy").setup({
    --                 -- preset = "slate",
    --                 preset = "miami-nights",
    --             })
    --         end,
    --     },
}
