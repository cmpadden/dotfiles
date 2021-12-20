--------------------------------------------------------------------------------
--                             Window Management                              --
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/go/#winlayout
-- https://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html
-- https://www.hammerspoon.org/Spoons/WindowScreenLeftAndRight.html

hs.window.animationDuration = 0

local left33 = hs.geometry.rect(0, 0, 0.3333, 1)
local right66 = hs.geometry.rect(0.3333, 0, 0.6666, 1)

local LAYOUT_WIDESCREEN = {
    { "Safari", nil, display_primary, left33, nil, nil },
    { "Terminal", nil, display_primary, right66, nil, nil },
    { "Spotify", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Slack", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Discord", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Messages", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Calendar", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Mail", nil, display_secondary, hs.layout.maximized, nil, nil },
}

local LAYOUT_DEFAULT = {
    { "Safari", nil, display_primary, hs.layout.maximized, nil, nil },
    { "kitty", nil, display_primary, hs.layout.maximized, nil, nil },
    { "Terminal", nil, display_primary, hs.layout.maximized, nil, nil },
    { "Notion", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Spotify", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Slack", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Discord", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Messages", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Calendar", nil, display_secondary, hs.layout.maximized, nil, nil },
    { "Mail", nil, display_secondary, hs.layout.maximized, nil, nil },
}

spoon.SpoonInstall:andUse("WindowScreenLeftAndRight", {
    hotkeys = {
        screen_left = { { "control", "cmd" }, "Left" },
        screen_right = { { "control", "cmd" }, "Right" },
    },
})

spoon.SpoonInstall:andUse("WindowHalfsAndThirds", {
    hotkeys = {
        third_left = { { "cmd" }, "Left" },
        left_half = { { "cmd", "shift" }, "Left" },
        third_right = { { "cmd" }, "Right" },
        right_half = { { "cmd", "shift" }, "Right" },
        max_toggle = { { "cmd", "shift" }, "Up" },
        center = { { "cmd" }, "Up" },
    },
})

hs.hotkey.bind({ "cmd", "ctrl" }, "1", function()
    -- assign primary display to both varaibles to start
    local display_primary = hs.screen.allScreens()[1]:name()
    local display_secondary = hs.screen.allScreens()[1]:name()

    -- if multiple displays are attatched, re-assign secondary display
    local num_screens = #hs.screen.allScreens()
    if num_screens > 1 then
        display_secondary = hs.screen.allScreens()[2]:name()
    end

    -- layout specificly for the ultrawide
    if display_primary == 'DELL U3419W' then
      window_layout = LAYOUT_WIDESCREEN
    else
      window_layout = LAYOUT_DEFAULT
    end

    hs.alert.show(string.format(
        [[
Primary Window Layout
----------------------------------------
Display #1: %s
Display #2: %s]],
        display_primary,
        display_secondary
    ))
    hs.layout.apply(window_layout)
end)
