return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "joosepalviste/nvim-ts-context-commentstring",
            "windwp/nvim-ts-autotag",
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TSUpdateSync" },
        build = ":TSUpdate",
        config = function()
            -- https://github.com/JoosepAlviste/nvim-ts-context-commentstring#getting-started
            vim.g.skip_ts_context_commentstring_module = true

            require("nvim-treesitter.configs").setup({
                enable_autocmd = false,
            })

            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash",
                    "css",
                    "diff",
                    "gitignore",
                    "hcl",
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
                highlight = {
                    enable = true,
                    disable = function(_, bufnr)
                        return vim.api.nvim_buf_line_count(bufnr) > 10000
                    end,
                },
                incremental_selection = { enable = true },
                indent = { enable = false },
                autotag = { enable = true },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["ak"] = "@block.outer",
                            ["ik"] = "@block.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["a?"] = "@conditional.outer",
                            ["i?"] = "@conditional.inner",
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["al"] = "@loop.outer",
                            ["il"] = "@loop.inner",
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]k"] = {
                                query = "@block.outer",
                                desc = "Next block start",
                            },
                            ["]f"] = {
                                query = "@function.outer",
                                desc = "Next function start",
                            },
                            ["]a"] = {
                                query = "@parameter.outer",
                                desc = "Next parameter start",
                            },
                        },
                        goto_next_end = {
                            ["]k"] = { query = "@block.outer", desc = "Next block end" },
                            ["]f"] = {
                                query = "@function.outer",
                                desc = "Next function end",
                            },
                            ["]a"] = {
                                query = "@parameter.outer",
                                desc = "Next parameter end",
                            },
                        },
                        goto_previous_start = {
                            ["[k"] = {
                                query = "@block.outer",
                                desc = "Previous block start",
                            },
                            ["[f"] = {
                                query = "@function.outer",
                                desc = "Previous function start",
                            },
                            ["[a"] = {
                                query = "@parameter.outer",
                                desc = "Previous parameter start",
                            },
                        },
                        goto_previous_end = {
                            ["[K"] = {
                                query = "@block.outer",
                                desc = "Previous block end",
                            },
                            ["[F"] = {
                                query = "@function.outer",
                                desc = "Previous function end",
                            },
                            ["[A"] = {
                                query = "@parameter.outer",
                                desc = "Previous parameter end",
                            },
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            [">K"] = {
                                query = "@block.outer",
                                desc = "Swap next block",
                            },
                            [">F"] = {
                                query = "@function.outer",
                                desc = "Swap next function",
                            },
                            [">A"] = {
                                query = "@parameter.inner",
                                desc = "Swap next parameter",
                            },
                        },
                        swap_previous = {
                            ["<K"] = {
                                query = "@block.outer",
                                desc = "Swap previous block",
                            },
                            ["<F"] = {
                                query = "@function.outer",
                                desc = "Swap previous function",
                            },
                            ["<A"] = {
                                query = "@parameter.inner",
                                desc = "Swap previous parameter",
                            },
                        },
                    },
                },
            })
        end,
    },
}
