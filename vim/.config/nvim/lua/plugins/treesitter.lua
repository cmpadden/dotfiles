return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            -- https://github.com/joosepalviste/nvim-ts-context-commentstring
            { "joosepalviste/nvim-ts-context-commentstring" },
            -- https://github.com/windwp/nvim-ts-autotag
            { "windwp/nvim-ts-autotag" },
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
                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                    -- Disable slow treesitter highlight for large files
                    disable = function(lang, buf)
                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                },
                incremental_selection = { enable = true },
                indent = { enable = false },
                autotag = { enable = true },
            })
        end,
    },

    -- https://github.com/nvim-treesitter/playground
    { "nvim-treesitter/playground" },
}
