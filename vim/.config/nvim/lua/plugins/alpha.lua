return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
        local path_ok, dashboard = pcall(require, "alpha.themes.dashboard")

        if not path_ok then
            return
        end

        -- https://textart.sh/topic/ghost
        dashboard.section.header.val = {
            "                          ░░░░░░░░░░                            ",
            "                      ▒▒▒▒░░░░░░░░░░░░▒▒▒▒                      ",
            "                  ░░                ░░░░░░░░░░                  ",
            "                ▒▒                      ░░░░░░▒▒                ",
            "              ░░░░                      ░░░░░░▓▓                ",
            "              ▓▓  ▒▒▓▓    ░░██▒▒          ░░░░░░▒▒              ",
            "              ▓▓  ██▓▓    ░░████▒▒        ░░░░░░▒▒              ",
            "        ░░░░  ▓▓  ▒▒▒▒      ▒▒▒▒▒▒        ░░░░░░▒▒              ",
            "      ▒▒                          ▒▒▒▒▒▒▒▒░░░░░░░░              ",
            "    ▓▓          ░░            ▒▒            ▒▒░░░░              ",
            "  ▓▓          ░░░░          ▒▒                ░░░░              ",
            "  ▒▒        ░░░░░░          ▒▒░░░░            ░░░░              ",
            "  ▒▒      ░░░░░░░░            ▒▒░░▒▒          ░░░░              ",
            "      ▓▓░░░░▒▒░░░░    ░░        ▒▒░░░░          ░░▒▒            ",
            "          ▒▒▒▒░░░░    ░░      ░░░░▒▒░░▒▒    ░░  ░░▒▒            ",
            "            ▓▓░░░░    ░░      ░░░░░░▒▒▒▒    ░░  ░░▒▒            ",
            "            ▓▓░░░░    ░░      ░░░░░░░░▒▒    ░░░░░░░░▒▒          ",
            "            ▓▓░░░░    ░░        ░░░░░░░░░░    ░░░░░░▒▒          ",
            "            ▓▓░░░░    ░░░░      ░░░░░░░░░░    ░░░░░░░░░░        ",
            "              ▓▓░░░░  ░░░░      ░░░░░░░░░░░░    ░░░░░░▒▒        ",
            "              ▒▒▒▒░░░░░░░░▒▒▒▒░░░░░░░░░░░░░░░░    ░░░░░░▒▒      ",
            "                ▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░░░      ",
            "                      ▒▒▒▒▒▒▒▒          ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ",
            "                                                                ",
            "                                                                ",
            "                                                                ",
            "                                                                ",
            "                          ░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓            ",
            "                  ░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓      ",
            "                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ",
            "                  ░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒      ",
        }
        dashboard.section.header.opts.hl = "DashboardHeader"

        dashboard.section.buttons.val = {
            dashboard.button("i", "> New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", "> Find file", ":FzfLua files<CR>"),
            dashboard.button("s", "> Settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
            dashboard.button("q", "> Quit", ":qa<CR>"),
        }

        dashboard.config.layout[1].val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) })
        dashboard.config.layout[3].val = 5
        dashboard.config.opts.noautocmd = true

        return dashboard.config
    end,
}