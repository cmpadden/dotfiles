-- see :h lua-vim-options

vim.opt.listchars = { tab = ">-", trail = ".", extends = ">" }
vim.opt.list = true

vim.opt.swapfile = false

vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.softtabstop = 0

vim.opt.textwidth = 88
vim.opt.colorcolumn = "80,88"

vim.opt.dictionary = "/usr/share/dict/words"

-- language servers can have issues with backup files
vim.opt.backup = false
vim.opt.writebackup = false

-- colorscheme
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true -- support true colors
vim.cmd("colorscheme tokyonight-night")

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevelstart = 99

-- new in 0.8.0!
vim.opt.ls = 0
vim.opt.ch = 0
-- set winbar=%f
