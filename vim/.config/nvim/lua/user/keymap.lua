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

-- external call to `chatblade`
-- prompts (eg. `programmer`) can be found in `~/.config/chatblade/`
vim.keymap.set("v", "<leader>c", ":!chatblade -r -p programmer<CR>")
vim.keymap.set("v", "<leader>cx", ":!chatblade -e -r -p programmer<CR>")
vim.keymap.set("v", "<leader>cd", ":!chatblade -r -p document<CR>")
vim.keymap.set("v", "<leader>ce", ":!chatblade -r -p explain<CR>")
