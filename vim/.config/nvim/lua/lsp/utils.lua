-- Shared utilities for LSP server configuration
local M = {}

-- Get LSP capabilities including blink.cmp integration
function M.get_capabilities()
    return vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("blink.cmp").get_lsp_capabilities({}, false)
    )
end

-- Base configuration applied to all servers
M.base_config = {
    capabilities = M.get_capabilities(),
    flags = { debounce_text_changes = 150 },
}

return M
