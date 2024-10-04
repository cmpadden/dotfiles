BANNER_1 = {
    "                                                                                  .-. .-')   ",
    "                                                                                  \\  ( OO )  ",
    "  ,--. .--------.      .--------. .-----.         ,--.      ,------.        ,--.   ;-----.\\  ",
    " /  .' |   __   '      |   __   '/ ,-.   \\       /  .'   ('-| _.---'       /  .'   | .-.  |  ",
    ".  / -.`--' .  /       `--' .  / '-'  |  |      .  / -.  (OO|(_\\          .  / -.  | '-' /_) ",
    "| .-.  '   /  /            /  /     .'  /       | .-.  ' /  |  '--.       | .-.  ' | .-. `.  ",
    "' \\  |  | .  /            .  /    .'  /__       ' \\  |  |\\_)|  .--'       ' \\  |  || |  \\  | ",
    "\\  `'  / /  /            /  /    |       |      \\  `'  /   \\|  |_)        \\  `'  / | '--'  / ",
    " `----' `--'            `--'     `-------'       `----'     `--'           `----'  `------'  ",
}

return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    init = false,
    opts = function()
        local path_ok, dashboard = pcall(require, "alpha.themes.dashboard")

        if not path_ok then
            return
        end

        dashboard.section.header.val = BANNER_1
        dashboard.section.header.opts.hl = "DashboardHeader"

        dashboard.section.buttons.val = {}
        dashboard.section.buttons.val = {
            dashboard.button("i", ">  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", ">  Find file", ":FzfLua files<CR>"),
            dashboard.button("q", ">  Quit", ":qa<CR>"),
        }
        dashboard.config.layout[3].val = 5
        dashboard.config.opts.noautocmd = true

        dashboard.config.layout[1].val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) })
        dashboard.section.footer.opts.hl = "AlphaFooter"
        return dashboard
    end,
    config = function(_, dashboard)
        if vim.o.filetype == "lazy" then
            vim.cmd.close()
            vim.api.nvim_create_autocmd("User", {
                pattern = "AlphaReady",
                callback = require("lazy").show(),
            })
        end

        require("alpha").setup(dashboard.opts)

        -- https://github.com/LazyVim/LazyVim/blob/592074ad802be2462306d3991024f350571dfab2/lua/lazyvim/plugins/ui.lua#L261C1-L283C9
        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyVimStarted",
            callback = function()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                dashboard.section.footer.val = stats.loaded
                    .. "/"
                    .. stats.count
                    .. " "
                    .. ms
                    .. "ms"
                pcall(vim.cmd.AlphaRedraw)
            end,
        })
    end,
}
