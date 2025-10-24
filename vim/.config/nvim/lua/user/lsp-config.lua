-- Native Neovim 0.11+ LSP configuration
-- Migrated from nvim-lspconfig to use pure vim.lsp.config() API
--
-- Previously used:
--   - neovim/nvim-lspconfig (for preconfigured server settings)
--   - williamboman/mason-lspconfig.nvim (for auto-installation bridge)
--
-- Now uses:
--   - Native vim.lsp.config() for all server configuration
--   - lua/lsp/servers.lua for explicit server definitions
--   - mason.nvim (optional) for installing language servers
--
-- Benefits:
--   - No plugin conflicts or overrides (like the basedpyright on_attach issue)
--   - Explicit, transparent configuration
--   - Faster startup (fewer plugins)
--   - Uses modern Neovim 0.11+ APIs

-- Configure diagnostic display
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
