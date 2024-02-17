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
      dir = "~/workspace/chatblade.nvim",
      keys = {
        { "<leader>x", ":Chatblade<cr><cr>", mode = "v", desc = "Chatblade" },
      },
      opts = {
        prompt  = "programmer", -- custom prompt: nil, 'programmer', 'explain', etc
        raw     = true,         -- print session as pure text
        extract = true,         -- extract content from response if possible (either json or code)
        only    = true,         -- only display the response, not the query
      }
    }

}
