local M = {}

function M.setup()
    require("diffview").setup({
        use_icons = false,
        show_help_hints = false,
        view = {
            default = {
                winbar_info = false,
            },
        },
        hooks = {
            view_opened = function(view)
                view.panel:close()
            end,
            diff_buf_win_enter = function(_, winid)
                vim.schedule(function()
                    if vim.api.nvim_win_is_valid(winid) then
                        vim.api.nvim_set_current_win(winid)
                    end
                end)
            end,
        },
    })
end

return M
