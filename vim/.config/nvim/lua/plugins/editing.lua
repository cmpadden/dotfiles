local M = {}

function M.setup()
    -- https://github.com/jpalardy/vim-slime
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
    vim.g.slime_bracketed_paste = 1

    -- https://codeberg.org/andyg/leap.nvim
    vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
    vim.keymap.set("n", "S", "<Plug>(leap-from-window)")

    -- https://github.com/junegunn/vim-easy-align
    vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
    vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")
end

return M
