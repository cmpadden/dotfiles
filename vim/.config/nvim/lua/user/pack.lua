-- Native Neovim package configuration.

if not vim.pack then
    error("vim.pack requires Neovim 0.12 or later")
end

local github = "https://github.com/"
local setup_modules = {
    ["saghen/blink.cmp"] = "blink.cmp",
    ["WhoIsSethDaniel/mason-tool-installer.nvim"] = "mason-tool-installer",
    ["stevearc/conform.nvim"] = "conform",
    ["ellisonleao/carbon-now.nvim"] = "carbon-now",
    ["ibhagwan/fzf-lua"] = "fzf-lua",
}
local versions = {
    ["L3MON4D3/LuaSnip"] = vim.version.range("2.0"),
    ["saghen/blink.cmp"] = vim.version.range("1.0"),
}

local modules = {
    require("plugins.colors"),
    require("plugins.snippets"),
    require("plugins.cmp"),
    require("plugins.treesitter"),
    require("plugins.extensions"),
    require("plugins.alpha"),
    require("plugins.personal"),
}

local specs = {}
local configured = {}

local function add(spec)
    if type(spec) == "string" then
        spec = { spec }
    end

    if spec.enabled == false then
        return
    end

    local repo = spec[1]
    if not repo then
        return
    end

    if not specs[repo] then
        specs[repo] = {
            src = github .. repo,
            version = versions[repo],
        }
    end

    for _, dependency in ipairs(spec.dependencies or {}) do
        add(dependency)
    end

    table.insert(configured, spec)
end

for _, module in ipairs(modules) do
    if module[1] and type(module[1]) == "string" then
        add(module)
    else
        for _, spec in ipairs(module) do
            add(spec)
        end
    end
end

vim.pack.add(vim.tbl_values(specs), { confirm = false })

for _, spec in ipairs(configured) do
    if type(spec.init) == "function" then
        spec.init()
    end
end

for _, spec in ipairs(configured) do
    local opts = spec.opts
    if type(opts) == "function" then
        opts = opts()
    end

    if type(spec.config) == "function" then
        spec.config(spec, opts)
    elseif opts then
        local module = setup_modules[spec[1]]
        if not module then
            error("No vim.pack setup module configured for " .. spec[1])
        end
        require(module).setup(opts)
    end
end
