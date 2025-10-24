local utils = require('lsp.utils')

return vim.tbl_extend("force", utils.base_config, {
    cmd = { utils.mason_bin .. 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html', 'templ' },
    root_markers = { 'package.json', '.git' },
    init_options = {
        configurationSection = { 'html', 'css', 'javascript' },
        embeddedLanguages = {
            css = true,
            javascript = true,
        },
        provideFormatter = true,
    },
    settings = {},
})
