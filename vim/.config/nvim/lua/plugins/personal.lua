--------------------------------------------------------------------------------
--                                  Personal                                  --
--------------------------------------------------------------------------------

local obj = {
    -- https://github.com/cmpadden/pomodoro.nvim
    {
        "cmpadden/pomodoro.nvim",
        config = function()
            require("pomodoro").setup()
        end,
    },
}

-- https://github.com/cmpadden/chatblade.nvim
if vim.fn.isdirectory(vim.fn.expand("~/src/llm.nvim")) == 1 then
    table.insert(obj, {
        dir = "~/src/llm.nvim",
        keys = {
            { "<leader>x", ":LLM<cr><cr>", mode = "v" },
        },
        cmd = {
            "LLM",
        },
        opts = {
            -- `llm` flag configuration parameters
            model             = "claude-3.5-haiku", -- TEXT            Model to use
            system            = nil,        -- TEXT            System prompt to use
            continue          = nil,        --                 Continue the most recent conversation.
            conversation      = nil,        -- TEXT            Continue the conversation with the given ID.
            template          = nil,        -- TEXT            Template to use
            param             = nil,        -- <TEXT TEXT>...  Parameters for template
            option            = nil,        -- <TEXT TEXT>...  key/value options for the model

            -- nvim-specific configuration parameters
            insert_as_comment = true -- BOOL            Insert the prompt response as a comment
        }
    })
end

-- https://github.com/PedramNavid/dbtpaluse
if vim.fn.isdirectory(vim.fn.expand("~/src/dbtpal")) == 1 then
    table.insert(obj, {
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
            -- vim.keymap.set("n", "<leader>du", require("dbtpal.telescope").dbt_picker_upstream)
            -- vim.keymap.set("n", "<leader>dd", require("dbtpal.telescope").dbt_picker_downstream)


            require("telescope").load_extension("dbtpal")
        end,
    })
end

return obj
