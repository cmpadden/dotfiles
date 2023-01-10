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

}
