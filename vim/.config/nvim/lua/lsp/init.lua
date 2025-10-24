local M = {}

-- auto-discover and load all server configurations
function M.load_servers()
    local servers = {}
    local servers_path = vim.fn.stdpath('config') .. '/lua/lsp/servers'

    if vim.fn.isdirectory(servers_path) == 0 then
        vim.notify('LSP servers directory not found: ' .. servers_path, vim.log.levels.ERROR)
        return servers
    end

    local files = vim.fn.readdir(servers_path, function(name)
        return name:match('%.lua$')
    end)

    for _, file in ipairs(files) do
        local server_name = file:gsub('%.lua$', '')
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
