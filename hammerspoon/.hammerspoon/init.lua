-- ~/.hammerspoon/init.lua

-- https://www.hammerspoon.org/

-- custom styling for alerts
hs.alert.defaultStyle.textColor = { hex = "#000000", alpha = 1 }
hs.alert.defaultStyle.textFont = "Courier"
hs.alert.defaultStyle.textSize = 12
hs.alert.defaultStyle.fillColor = { hex = "#FFFFFF", alpha = 0.95 }
hs.alert.defaultStyle.strokeColor = { hex = "#000000", alpha = 0.95 }
hs.alert.defaultStyle.strokeWidth = 2
hs.alert.defaultStyle.padding = 12
hs.alert.defaultStyle.radius = 1
hs.alert.defaultStyle.fadeInDuration = 0
hs.alert.defaultStyle.fadeOutDuration = 2

-- https://www.hammerspoon.org/docs/hs.ipc.html#cliInstall
-- https://github.com/Hammerspoon/hammerspoon/issues/2930#issuecomment-899092002
if not hs.ipc.cliStatus("/opt/homebrew") then
    hs.ipc.cliInstall("/opt/homebrew")
end

-- global hotkey prefix key combinations (used in modules)
HYPER = { "cmd", "ctrl" }
HYPER_SHIFT = { "cmd", "ctrl", "shift" }

require("modules.plugins")
-- require("modules.alerts")
require("modules.caffeine")
-- require("modules.watchers")

-- WINDOW_MANAGER = require("modules.window")
-- WINDOW_MANAGER:init()

require("modules.hhtwm")


-- Custom Spoons

-- hs.loadSpoon("Pass")
-- spoon.Pass:bindHotkeys({
--     toggle_pass = { { "cmd", "ctrl" }, "p" },
--     toggle_otp = { { "cmd", "ctrl" }, "o" },
-- })

hs.alert.show("Configuration Loaded")
