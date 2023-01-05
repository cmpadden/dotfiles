-- If you plan to use per-project virtualenvs often, you should assign one virtualenv
-- for Neovim and hard-code the interpreter path via |g:python3_host_prog| so that the
-- "pynvim" package is not required for each virtualenv.
vim.g.python3_host_prog = "/usr/bin/python3"

-- use pythonic folding for vim-markdown
vim.g.vim_markdown_folding_style_pythonic = 1

-- Goyo

vim.g.goyo_height = "100%"

-- Slime

vim.g.slime_target = "tmux"
vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
vim.g.slime_dont_ask_default = 1

-- EditorConfig

vim.g.EditorConfig_exclude_patterns = { "fugitive://.*", "scp://.*" }

-- disable persistant directory listings

vim.g.netrw_fastbrowse = 0

-- markdown-preview
-- open the preview window after entering the markdown buffer

vim.g.mkdp_auto_start = 0
