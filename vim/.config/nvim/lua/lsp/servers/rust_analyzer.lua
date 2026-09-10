local utils = require("lsp.utils")

return vim.tbl_extend("force", utils.base_config, {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json" },
    settings = {
        ["rust-analyzer"] = {},
    },
})
