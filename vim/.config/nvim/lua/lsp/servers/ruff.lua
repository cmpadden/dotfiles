local utils = require("lsp.utils")

return vim.tbl_extend("force", utils.base_config, {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    settings = {},
})
