-----------------------------------------------------------------------------------------
--                                      init.lua                                       --
-----------------------------------------------------------------------------------------

vim.g.mapleader = " " -- <space>
vim.g.maplocalleader = ","

require("user.lazy")
require("user.globals")
require("user.options")
require("user.keymap")
require("user.commands")
require("user.augroups")

vim.cmd([[
  if filereadable(expand("$HOME") . "/.config/nvim/work.vim")
    runtime work.vim
  endif
]])
