return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "joosepalviste/nvim-ts-context-commentstring",
            "windwp/nvim-ts-autotag",
            -- "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("nvim-treesitter.configs").setup({
                cmd = {
                    "TSBufDisable",
                    "TSBufEnable",
                    "TSBufToggle",
                    "TSDisable",
                    "TSEnable",
                    "TSToggle",
                    "TSInstall",
                    "TSInstallInfo",
                    "TSInstallSync",
                    "TSModuleInfo",
                    "TSUninstall",
                    "TSUpdate",
                    "TSUpdateSync",
                },
                build = ":TSUpdate",
                ensure_installed = {
                    "bash",
                    "css",
                    "diff",
                    "gitignore",
                    "hcl",
                    "help",
                    "html",
                    "http",
                    "javascript",
                    "jsdoc",
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "python",
                    "rust",
                    "sql",
                    "toml",
                    "typescript",
                    "vue",
                    "yaml",
                },
                context_commentstring = { enable = true, enable_autocmd = false },
                highlight = {
                    enable = true,
                    disable = function(_, bufnr)
                        return vim.api.nvim_buf_line_count(bufnr) > 10000
                    end,
                },
                incremental_selection = { enable = true },
                indent = { enable = false },
                autotag = { enable = true },
                opts = {
                    autotag = { enable = true },
                    context_commentstring = { enable = true, enable_autocmd = false },
                    highlight = {
                        enable = true,
                        disable = function(_, bufnr)
                            return vim.api.nvim_buf_line_count(bufnr) > 10000
                        end,
                    },
                    incremental_selection = { enable = true },
                    indent = { enable = true },
                },
            })
        end,
    },
}
