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
                ensure_installed = {
                    "black",
                    "flake8",
                    "isort",
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
