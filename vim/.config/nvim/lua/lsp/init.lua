local M = {}

local servers = {
    "bashls",
    "eslint",
    "html",
    "jsonls",
    "lua_ls",
    "ruff",
    "rust_analyzer",
    "tailwindcss",
    "vtsls",
    "yamlls",
}

function M.setup()
    for _, name in ipairs(servers) do
        vim.lsp.config(name, require("lsp.servers." .. name))
    end

    vim.lsp.enable(servers)
end

return M
