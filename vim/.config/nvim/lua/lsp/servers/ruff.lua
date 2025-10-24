-- Server-specific settings for ruff.
-- Tries project-local .venv/bin/ruff first, fallback to mason-installed ruff

local utils = require('lsp.utils')

return vim.tbl_extend("force", utils.base_config, {
    -- Try project-local ruff first, fallback to mason-installed ruff
    cmd = (function()
        local local_ruff = vim.fn.getcwd() .. '/.venv/bin/ruff'
        if vim.fn.executable(local_ruff) == 1 then
            return { local_ruff, 'server' }
        else
            return { utils.mason_bin .. 'ruff', 'server' }
        end
    end)(),
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
    settings = {},
})
