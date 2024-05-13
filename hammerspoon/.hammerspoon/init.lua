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
require("modules.draw")

local wm = require("modules.window")

local split_padding = 0.08
local padding = 0.02
local window_width_centered = 0.65
local window_width_skinny = 0.35
local pip_height = 0.35
local pip_width = 0.142

local RECT_CENTER = hs.geometry({
    h = (1 - (2 * padding)),
    w = window_width_centered,
    x = ((1 - window_width_centered) / 2),
    y = padding,
})

local RECT_LEFT = hs.geometry({
    h = (1 - (2 * padding)),
    w = (0.5 - (split_padding + 0.005)),
    x = split_padding,
    y = padding,
})

local RECT_RIGHT = hs.geometry({
    h = (1 - (2 * padding)),
    w = (0.5 - split_padding - 0.005),
    x = (0.5 + 0.005),
    y = padding,
})

local RECT_SKINNY = hs.geometry({
    h = (1 - (2 * padding)),
    w = window_width_skinny,
    x = ((1 - window_width_skinny) / 2),
    y = padding,
})

local PIP_BOTTOM_RIGHT = hs.geometry({
    h = pip_height,
    w = pip_width,
    x = (1 - 0.162),
    y = ((1 - pip_height) - padding),
})

local PIP_TOP_RIGHT = hs.geometry({
    h = pip_height,
    w = pip_width,
    x = padding,
    y = padding,
})

wm.config.layouts = {
    [1] = {
        RECT_LEFT,
        RECT_RIGHT,
    },
    [2] = {
        RECT_LEFT,
        RECT_RIGHT,
        PIP_BOTTOM_RIGHT,
    },
    [3] = {
        RECT_CENTER,
        PIP_BOTTOM_RIGHT,
    },
    [4] = {
        RECT_SKINNY,
        PIP_TOP_RIGHT,
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
