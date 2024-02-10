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

-- `chatblade`
-- * prompts (eg. `programmer`) can be found in `~/.config/chatblade/`
-- * `<leader>c` defaults to `-e` extracting the content
vim.keymap.set("v", "<leader>c", ':!chatblade -e -r -p programmer<CR>')
vim.keymap.set("v", "<leader>fc", ':!chatblade -r -p programmer<CR>')
vim.keymap.set("v", "<leader>e", ':!chatblade -e -r -p explain<CR>')
vim.keymap.set("v", "<leader>fe", ':!chatblade -r -p explain<CR>')

-- Future enhancement would be to not replace the current visual selection, but instead
-- place the command output below the selection. This may be possible by using
-- registers, yanking the selection, passing the register to the command, and then
-- putting the register contents above the output.

-- source current Lua file
vim.keymap.set("n", "<leader>ss", ":luafile %<CR>")
