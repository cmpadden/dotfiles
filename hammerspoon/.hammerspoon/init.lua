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
require("modules.window"):init()

if not hs.ipc.cliStatus("/opt/homebrew") then
    hs.ipc.cliInstall("/opt/homebrew")
end

hs.alert.show("Completed load of `main.fnl`")
