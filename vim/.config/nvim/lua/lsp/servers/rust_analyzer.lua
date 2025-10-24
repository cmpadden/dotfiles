local utils = require('lsp.utils')

return vim.tbl_extend("force", utils.base_config, {
    cmd = { utils.mason_bin .. 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json' },
    settings = {
        ['rust-analyzer'] = {},
    },
})
