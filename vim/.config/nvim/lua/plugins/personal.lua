--------------------------------------------------------------------------------
--                                  Personal                                  --
--------------------------------------------------------------------------------

return {
    -- https://github.com/cmpadden/pomodoro.nvim
    {
        "cmpadden/pomodoro.nvim",
        config = function()
            require("pomodoro").setup()
        end,
    },

    -- https://github.com/cmpadden/chatblade.nvim
    {
        dir = "~/src/chatblade.nvim",
        keys = {
            { "<leader>x", ":Chatblade<cr><cr>", mode = "v", desc = "Chatblade" },
        },
        cmd = {
            "Chatblade",
            "ChatbladeSessionStart",
            "ChatbladeSessionStop",
            "ChatbladeSessionDelete",
        },
        opts = {
            prompt = "programmer",
            raw = true,
            extract = true,
            only = true,
        },
    },

    -- https://github.com/PedramNavid/dbtpaluse
    {
        dir = "~/src/dbtpal",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            local dbt = require("dbtpal")

            dbt.setup({
                path_to_dbt = "dbt",
                path_to_dbt_project = "",
                path_to_dbt_profiles_dir = vim.fn.expand("~/.dbt"),
                extended_path_search = true,
                protect_compiled_files = true,
            })

            vim.keymap.set("n", "<leader>drf", dbt.run)
            vim.keymap.set("n", "<leader>drp", dbt.run_all)
            vim.keymap.set("n", "<leader>dtf", dbt.test)
            vim.keymap.set("n", "<leader>dm", require("dbtpal.telescope").dbt_picker)

            require("telescope").load_extension("dbtpal")
        end,
    },
}
