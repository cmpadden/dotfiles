vim.diagnostic.config({
    virtual_text = false,
    underline = true,
    update_in_insert = false,
    severity_sort = false,
    -- https://neovim.io/doc/user/diagnostic.html#diagnostic-signs
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '•',
            [vim.diagnostic.severity.WARN] = '•',
        },
    },
})

-- Setup all LSP servers from lua/lsp/servers.lua
require('lsp.servers').setup()
