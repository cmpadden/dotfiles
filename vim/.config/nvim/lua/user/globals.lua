-- If you plan to use per-project virtualenvs often, you should assign one virtualenv
-- for Neovim and hard-code the interpreter path via |g:python3_host_prog| so that the
-- "pynvim" package is not required for each virtualenv.
vim.g.python3_host_prog = "/usr/bin/python3"

-- disable persistant directory listings
vim.g.netrw_fastbrowse = 0
