--------------------------------------------------------------------------------
--                                   Colors                                   --
--------------------------------------------------------------------------------

return {

    -- Error: `invalid node type at position 2765 for language vim`
    -- Solution:
    -- > rm /opt/homebrew/lib/nvim/parser/vim.so

    -- -- https://github.com/EdenEast/nightfox.nvim
    -- {
    --     "EdenEast/nightfox.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     init = function()
    --         vim.cmd.colorscheme("terafox")
    --     end,
    -- },

    -- https://github.com/catppuccin/nvim
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        init = function()
            require("catppuccin").setup({
                flavour = "macchiato", -- latte / frappe / mocha
                term_colors = true,
                transparent_background = false,
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },
}
