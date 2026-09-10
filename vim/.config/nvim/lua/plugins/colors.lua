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

local M = {}

function M.setup()
    vim.o.termguicolors = true
    vim.cmd.colorscheme("carbonfox")
end

return M
