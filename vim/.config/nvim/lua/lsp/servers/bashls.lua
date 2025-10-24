local utils = require('lsp.utils')

return vim.tbl_extend("force", utils.base_config, {
    cmd = { utils.mason_bin .. 'bash-language-server', 'start' },
    filetypes = { 'bash', 'sh' },
    root_markers = { '.git' },
    settings = {
        bashIde = {
            globPattern = '*@(.sh|.inc|.bash|.command)',
        },
    },
})
