-- Pure Neovim 0.11+ LSP configuration
-- This replaces nvim-lspconfig with native vim.lsp.config() API
--
-- Each server is explicitly configured with:
--   - cmd: Command to start the language server
--   - filetypes: Which filetypes trigger auto-start
--   - root_markers: Files/directories that indicate project root
--   - settings: Server-specific configuration
--
-- Benefits:
--   - No plugin conflicts (no nvim-lspconfig bundled configs to override)
--   - Explicit and transparent configuration
--   - Faster startup (fewer plugins)
--   - Modern Neovim 0.11+ APIs

local M = {}

-- Get the mason bin directory path
local mason_bin = vim.fn.stdpath('data') .. '/mason/bin/'

-- Get LSP capabilities for blink.cmp completion
local function get_capabilities()
    return vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('blink.cmp').get_lsp_capabilities({}, false)
    )
end

-- Base configuration shared across all servers
local base_config = {
    capabilities = get_capabilities(),
    on_attach = require("shared").default_on_attach,
    flags = { debounce_text_changes = 150 },
}

-- All LSP server configurations
-- Priority order for settings:
--   1. Inline settings defined here
--   2. Settings from lsp/<name>.lua files (merged via require)
M.servers = {
    -- Python: Type checking and diagnostics
    basedpyright = vim.tbl_extend("force", base_config, {
        cmd = { mason_bin .. 'basedpyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = {
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
            'pyrightconfig.json',
            '.git',
        },
        -- Load detailed settings from lsp/basedpyright.lua
        settings = require('lsp.basedpyright').settings,
    }),

    -- Bash: Shell script language server
    bashls = vim.tbl_extend("force", base_config, {
        cmd = { mason_bin .. 'bash-language-server', 'start' },
        filetypes = { 'bash', 'sh' },
        root_markers = { '.git' },
        settings = {
            bashIde = {
                globPattern = '*@(.sh|.inc|.bash|.command)',
            },
        },
    }),

    -- ESLint: JavaScript/TypeScript linting
    eslint = vim.tbl_extend("force", base_config, {
        cmd = { mason_bin .. 'vscode-eslint-language-server', '--stdio' },
        filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
            'vue',
            'svelte',
            'astro',
            'htmlangular',
        },
        root_markers = {
            '.eslintrc',
            '.eslintrc.js',
            '.eslintrc.cjs',
            '.eslintrc.yaml',
            '.eslintrc.yml',
            '.eslintrc.json',
            'eslint.config.js',
            'package.json',
        },
        settings = {
            codeAction = {
                disableRuleComment = {
                    enable = true,
                    location = 'separateLine',
                },
                showDocumentation = {
                    enable = true,
                },
            },
            codeActionOnSave = {
                enable = false,
                mode = 'all',
            },
            experimental = {
                useFlatConfig = false,
            },
            format = true,
            nodePath = '',
            onIgnoredFiles = 'off',
            problems = {
                shortenToSingleLine = false,
            },
            quiet = false,
            rulesCustomizations = {},
            run = 'onType',
            useESLintClass = false,
            validate = 'on',
            workingDirectory = {
                mode = 'auto',
            },
        },
    }),

    -- HTML: HTML language features
    html = vim.tbl_extend("force", base_config, {
        cmd = { mason_bin .. 'vscode-html-language-server', '--stdio' },
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
    }),

    -- JSON: JSON language features
    jsonls = vim.tbl_extend("force", base_config, {
        cmd = { mason_bin .. 'vscode-json-language-server', '--stdio' },
        filetypes = { 'json', 'jsonc' },
        root_markers = { '.git' },
        init_options = {
            provideFormatter = true,
        },
        settings = {},
    }),

    -- Lua: Lua language server (configured for Neovim)
    lua_ls = vim.tbl_extend("force", base_config, {
        cmd = { mason_bin .. 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = {
            '.luarc.json',
            '.luarc.jsonc',
            '.luacheckrc',
            '.stylua.toml',
            'stylua.toml',
            'selene.toml',
            'selene.yml',
            '.git',
        },
        -- Load settings from lsp/lua_ls.lua (adds vim, hs globals)
        settings = require('lsp.lua_ls').settings,
    }),

    -- Python: Fast linter and formatter
    ruff = vim.tbl_extend("force", base_config, {
        -- Try project-local ruff first, fallback to mason-installed ruff
        cmd = (function()
            local local_ruff = vim.fn.getcwd() .. '/.venv/bin/ruff'
            if vim.fn.executable(local_ruff) == 1 then
                return { local_ruff, 'server' }
            else
                return { mason_bin .. 'ruff', 'server' }
            end
        end)(),
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
        settings = {},
    }),

    -- Rust: Rust language server
    rust_analyzer = vim.tbl_extend("force", base_config, {
        cmd = { mason_bin .. 'rust-analyzer' },
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', 'rust-project.json' },
        settings = {
            ['rust-analyzer'] = {},
        },
    }),

    -- TailwindCSS: Tailwind CSS IntelliSense
    tailwindcss = vim.tbl_extend("force", base_config, {
        cmd = { mason_bin .. 'tailwindcss-language-server', '--stdio' },
        filetypes = {
            'aspnetcorerazor',
            'astro',
            'astro-markdown',
            'blade',
            'clojure',
            'django-html',
            'htmldjango',
            'edge',
            'eelixir',
            'elixir',
            'ejs',
            'erb',
            'eruby',
            'gohtml',
            'gohtmltmpl',
            'haml',
            'handlebars',
            'hbs',
            'html',
            'htmlangular',
            'html-eex',
            'heex',
            'jade',
            'leaf',
            'liquid',
            'markdown',
            'mdx',
            'mustache',
            'njk',
            'nunjucks',
            'php',
            'razor',
            'slim',
            'twig',
            'css',
            'less',
            'postcss',
            'sass',
            'scss',
            'stylus',
            'sugarss',
            'javascript',
            'javascriptreact',
            'reason',
            'rescript',
            'typescript',
            'typescriptreact',
            'vue',
            'svelte',
            'templ',
        },
        root_markers = {
            'tailwind.config.js',
            'tailwind.config.cjs',
            'tailwind.config.mjs',
            'tailwind.config.ts',
            'postcss.config.js',
            'postcss.config.cjs',
            'postcss.config.mjs',
            'postcss.config.ts',
            'package.json',
            '.git',
        },
        settings = {
            tailwindCSS = {
                classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass' },
                includeLanguages = {
                    eelixir = 'html-eex',
                    elixir = 'phoenix-heex',
                    eruby = 'erb',
                    heex = 'phoenix-heex',
                    htmlangular = 'html',
                    templ = 'html',
                },
                lint = {
                    cssConflict = 'warning',
                    invalidApply = 'error',
                    invalidConfigPath = 'error',
                    invalidScreen = 'error',
                    invalidTailwindDirective = 'error',
                    invalidVariant = 'error',
                    recommendedVariantOrder = 'warning',
                },
                validate = true,
            },
        },
    }),

    -- YAML: YAML language features
    -- Only configured if lsp/yamlls.lua exists
    yamlls = (function()
        local ok, yamlls_config = pcall(require, 'lsp.yamlls')
        if not ok then
            return nil
        end
        return vim.tbl_extend("force", base_config, {
            cmd = { mason_bin .. 'yaml-language-server', '--stdio' },
            filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
            root_markers = { '.git' },
            settings = yamlls_config.settings,
        })
    end)(),
}

-- Register and enable all configured LSP servers
function M.setup()
    -- Step 1: Register all server configurations
    for name, config in pairs(M.servers) do
        if config ~= nil then
            vim.lsp.config(name, config)
        end
    end

    -- Step 2: Enable all servers (actually starts them)
    -- In Neovim 0.11+, vim.lsp.config() only defines the config,
    -- vim.lsp.enable() actually starts the servers for matching filetypes
    local server_names = {}
    for name, config in pairs(M.servers) do
        if config ~= nil then
            table.insert(server_names, name)
        end
    end
    vim.lsp.enable(server_names)
end

return M
