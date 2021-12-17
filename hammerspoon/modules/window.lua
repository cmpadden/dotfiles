--------------------------------------------------------------------------------
--                             Window Management                              --
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/go/#winlayout
-- https://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html
-- https://www.hammerspoon.org/Spoons/WindowScreenLeftAndRight.html

hs.window.animationDuration = 0

spoon.SpoonInstall:andUse("WindowScreenLeftAndRight", {
    hotkeys = {
        screen_left = { { "cmd", "shift" }, "Left" },
        screen_right = { { "cmd", "shift" }, "Right" },
    },
})

spoon.SpoonInstall:andUse("WindowHalfsAndThirds", {
    hotkeys = {
        left_half = { { "cmd" }, "Left" },
        right_half = { { "cmd" }, "Right" },
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

    local window_layout = {
        { "Safari", nil, display_primary, hs.layout.maximized, nil, nil },
        { "kitty", nil, display_primary, hs.layout.maximized, nil, nil },
        { "Notion", nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Spotify", nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Slack", nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Discord", nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Messages", nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Calendar", nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Mail", nil, display_secondary, hs.layout.maximized, nil, nil },
    }

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
