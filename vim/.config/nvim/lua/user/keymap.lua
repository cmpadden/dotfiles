vim.g.mapleader = " " -- <space>

vim.g.maplocalleader = ","

-- edit and reload init.vim
vim.keymap.set("n", "<leader>ve", ":e " .. os.getenv("MYVIMRC") .. "<CR>")
vim.keymap.set("n", "<leader>vr", ":source " .. os.getenv("MYVIMRC") .. "<CR>")

-- fzf.lua
vim.keymap.set("n", "<c-f>f", "<cmd>lua require('fzf-lua').files()<CR>")
vim.keymap.set("n", "<c-f>n", "<cmd>lua require('fzf-lua').git_files()<CR>")
vim.keymap.set("n", "<c-f>l", "<cmd>lua require('fzf-lua').blines()<CR>")
vim.keymap.set("n", "<c-f>g", "<cmd>lua require('fzf-lua').live_grep()<CR>")
vim.keymap.set("n", "<c-f>h", "<cmd>lua require('fzf-lua').help_tags()<CR>")
vim.keymap.set("n", "<c-f>c", "<cmd>lua require('fzf-lua').git_bcommits()<CR>")
vim.keymap.set("n", "<c-f>b", "<cmd>lua require('fzf-lua').buffers()<CR>")

-- easy-align
vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")

-- buffer navigation
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>")

-- command navigation
vim.keymap.set("c", "<C-p>", "<Up>")
vim.keymap.set("c", "<C-n>", "<Down>")

-- repeated indentation
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- search visual selection
vim.keymap.set("v", "//", 'y/\\V<C-R>"<CR>')

-- copy to system clipboard
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>y", '"+y')

-- paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("n", "<leader>P", '"+P')
vim.keymap.set("v", "<leader>p", '"+p')
vim.keymap.set("v", "<leader>P", '"+P')
