-------------------------------------------------------------------------------
--                                   Colors                                   --
--------------------------------------------------------------------------------

-- Previous color schemes:
--
-- Verf/deepwhite.nvim
-- catppuccin/nvim
-- cocopon/iceberg.vim
-- ellisonleao/gruvbox.nvim
-- jesseleite/nvim-noirbuddy
-- mcchrish/zenbones.nvim
-- mellow-theme/mellow.nvim
-- nordtheme/vim
-- nyoom-engineering/oxocarbon.nvim
-- rebelot/kanagawa.nvim
-- scottmckendry/cyberdream.nvim
-- tanvirtin/monokai.nvim

return {
    -- https://github.com/EdenEast/nightfox.nvim
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.o.termguicolors = true
            vim.cmd.colorscheme("carbonfox")
        end,
    },
}
