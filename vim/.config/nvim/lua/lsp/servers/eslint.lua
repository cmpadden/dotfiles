local utils = require('lsp.utils')

return vim.tbl_extend("force", utils.base_config, {
    cmd = { utils.mason_bin .. 'vscode-eslint-language-server', '--stdio' },
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
})
