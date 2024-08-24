return {
    -- https://github.com/williamboman/mason.nvim
    {
        "williamboman/mason.nvim",
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonLog",
        },
        build = ":MasonUpdate",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
                ensure_installed = {
                    "codespell",
                    "prettier",
                    "ruff",
                    "shellcheck",
                    "shfmt",
                    "sqlfluff",
                    "stylua",
                    "vale",
                },
            })
        end,
    },
}
