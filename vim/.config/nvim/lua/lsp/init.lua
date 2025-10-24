local M = {}

-- auto-discover and load all server configurations
function M.load_servers()
    local servers = {}

    -- Use nvim's runtime file discovery to find all server configs
    local server_files = vim.api.nvim_get_runtime_file('lua/lsp/servers/*.lua', true)

    if #server_files == 0 then
        vim.notify('No LSP server configs found in lua/lsp/servers/', vim.log.levels.WARN)
        return servers
    end

    for _, filepath in ipairs(server_files) do
        -- Extract server name from filepath (e.g., "lua/lsp/servers/basedpyright.lua" -> "basedpyright")
        local server_name = vim.fn.fnamemodify(filepath, ':t:r')
        local ok, config = pcall(require, 'lsp.servers.' .. server_name)

        if ok then
            servers[server_name] = config
        else
            vim.notify(
                string.format('Failed to load LSP server config: %s\n%s', server_name, config),
                vim.log.levels.WARN
            )
        end
    end

    return servers
end

function M.setup()
    local servers = M.load_servers()

    -- register all server configurations with vim.lsp.config()
    for name, config in pairs(servers) do
        vim.lsp.config(name, config)
    end

    -- enable all registered servers
    local server_names = vim.tbl_keys(servers)
    if #server_names > 0 then
        vim.lsp.enable(server_names)
    end
end

return M
