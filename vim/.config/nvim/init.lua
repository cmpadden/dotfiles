-----------------------------------------------------------------------------------------
--                                      init.lua                                       --
-----------------------------------------------------------------------------------------

vim.g.mapleader = " " -- <space>
vim.g.maplocalleader = ","

-- NOTE: use `gx` to open a URL in the web browser

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

-- Testing of `chatblade.nvim`
vim.api.nvim_create_user_command("X", require("custom.chatblade").run, { range = true })
vim.keymap.set("v", "<leader>x", ":lua require('custom.chatblade').run()<CR>")
