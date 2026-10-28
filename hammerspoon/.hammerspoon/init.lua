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
-- require("modules.alerts")
require("modules.caffeine")

local glass_toast = require("modules.glass_toast")
local helpers = require("modules.helpers")
local wm = require("modules.wm")

-- Configure applications that should be ignored by window management
-- Use exact application names as returned by window:application():name()
wm.config.application_ignore_list = {
    "zoom.us",
}

wm.config.layouts = {
    -- ┌-----------─┐
    -- | [        ] |
    -- | [        ] |
    -- └------------┘
    {
        wm.builtins.full,
        wm.builtins.pip_bottom_right,
    },
    -- ┌-----------─┐
    -- | [   ][   ] |
    -- | [   ][   ] |
    -- └------------┘
    {
        wm.builtins.padded_left,
        wm.builtins.padded_right,
        wm.builtins.pip_bottom_right,
    },
    -- ┌-----------─┐
    -- |  [      ]  |
    -- |  [      ]  |
    -- └------------┘
    {
        wm.builtins.padded_center,
        wm.builtins.pip_bottom_right,
    },
    -- ┌-----------─┐
    -- |[    ][    ]|
    -- |[    ][    ]|
    -- └------------┘
    {
        wm.builtins.full_left,
        wm.builtins.full_right,
    },
    -- ┌-----------─┐
    -- |    [  ]    |
    -- |    [  ]    |
    -- └------------┘
    {
        wm.builtins.skinny,
        wm.builtins.pip_top_right,
    },
}

wm:init()

-- Preserve window-state persistence while closing the native chooser on reload.
local save_window_state = hs.shutdownCallback
hs.shutdownCallback = function()
    require("modules.chooser").shutdown()
    if save_window_state then
        save_window_state()
    end
end

hs.hotkey.bind({ "cmd", "shift" }, "b", function()
    local applescript_toggle_menubar = [[
    tell application "System Events"
        set autohide menu bar of dock preferences to (not autohide menu bar of dock preferences)
    end tell
    ]]
    hs.osascript.applescript(applescript_toggle_menubar)
end)

-- Loading hs.ipc starts the message port used by the persistent Hammerspoon CLI.
-- The CLI itself is installed separately, so do not recheck/reinstall it on reload.
require("hs.ipc")

glass_toast:show("reload", "Hammerspoon Reloaded", function()
    helpers:show("Hammerspoon Reloaded")
end)
