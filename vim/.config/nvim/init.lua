-- init.lua

vim.g.mapleader = " " -- <space>
vim.g.maplocalleader = ","

-- NOTE: use `gx` to open a URL in the web browser
require("user.lazy")
require("user.globals")
require("user.options")
require("user.keymap")
require("user.commands")
require("user.augroups")
require("user.lsp-config")

vim.cmd([[
  if filereadable(expand("$HOME") . "/.config/nvim/work.vim")
    runtime work.vim
  endif
]])
