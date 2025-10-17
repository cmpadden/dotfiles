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

-- vim.opt.textwidth = 88
-- vim.opt.colorcolumn = "80,88"

-- vim.opt.cursorcolumn = true
vim.opt.cursorline = true

vim.opt.textwidth = 100
-- vim.opt.colorcolumn = "100"
-- vim.cmd([[hi ColorColumn ctermbg=0 guibg=#625d7f]])

vim.opt.dictionary = "/usr/share/dict/words"

-- language servers can have issues with backup files
vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevelstart = 99

-- new in 0.8.0!
-- vim.opt.laststatus = 0
vim.opt.cmdheight = 0
-- set winbar=%f

vim.opt.number = true
