local utils = require("lsp.utils")

return vim.tbl_extend("force", utils.base_config, {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_markers = { ".git" },
    init_options = {
        provideFormatter = true,
    },
    settings = {},
})
