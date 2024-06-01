HYPER = { "cmd", "ctrl" }
HYPER_SHIFT = { "cmd", "ctrl", "shift" }

hs.alert.defaultStyle.textColor = { alpha = 1, hex = "#000000" }
hs.alert.defaultStyle.textFont = "Courier"
hs.alert.defaultStyle.textSize = 12
hs.alert.defaultStyle.fillColor = { alpha = 0.95, hex = "#FFFFFF" }
hs.alert.defaultStyle.strokeColor = { alpha = 0.95, hex = "#000000" }
hs.alert.defaultStyle.strokeWidth = 2
hs.alert.defaultStyle.padding = 12
hs.alert.defaultStyle.radius = 1
hs.alert.defaultStyle.fadeInDuration = 0
hs.alert.defaultStyle.fadeOutDuration = 2

require("modules.plugins")
require("modules.alerts")
require("modules.caffeine")

local wm = require("modules.window")

wm.config.layouts = {
    {
        wm.builtins.padded_left,
        wm.builtins.padded_right,
    },
    {
        wm.builtins.padded_left,
        wm.builtins.padded_right,
        wm.builtins.pip_bottom_right,
    },
    {
        wm.builtins.padded_center,
        wm.builtins.pip_bottom_right,
    },
    {
        wm.builtins.skinny,
        wm.builtins.pip_top_right,
    },
}

wm:init()

hs.hotkey.bind({ "cmd", "shift" }, "b", function()
    local applescript_toggle_menubar = [[
    tell application "System Events"
        set autohide menu bar of dock preferences to (not autohide menu bar of dock preferences)
    end tell
    ]]
    hs.osascript.applescript(applescript_toggle_menubar)
end)

if not hs.ipc.cliStatus("/opt/homebrew") then
    hs.ipc.cliInstall("/opt/homebrew")
end

hs.alert.show("Completed load of `main.fnl`")
