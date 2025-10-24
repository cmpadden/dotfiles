local utils = require('lsp.utils')

return vim.tbl_extend("force", utils.base_config, {
    cmd = { utils.mason_bin .. 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
    root_markers = { '.git' },
    settings = {
        yaml = {
            -- TODO - dynamically check if schemas are present
            schemas = {
                [".vscode/schema.json"] = "**/*.y*ml",
            },
        },
    },
})
