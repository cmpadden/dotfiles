--------------------------------------------------------------------------------
--                             Window Management                              --
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/go/#winlayout
-- https://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html
-- https://www.hammerspoon.org/Spoons/WindowScreenLeftAndRight.html

hs.window.animationDuration = 0

CENTER_60 = hs.geometry({ x = 0.3, y = 0.0, w = 0.4, h = 1.0 })
CENTER_66 = hs.geometry.rect({ x = 0.1666, y = 0, w = 0.6666, h = 1 })
LEFT_30 = hs.geometry({ x = 0.0, y = 0.0, w = 0.3, h = 1.0 })
LEFT_70 = hs.geometry({ x = 0.0, y = 0.0, w = 0.7, h = 1.0 })
RIGHT_30 = hs.geometry({ x = 0.70, y = 0.0, w = 0.3, h = 1.0 })
RIGHT_70 = hs.geometry({ x = 0.3, y = 0.0, w = 0.7, h = 1.0 })

-- |[ ][    ]|
local LAYOUT_PRIMARY = {
    { "Calendar",  nil, nil, LEFT_30, nil, nil },
    { "Chromium",  nil, nil, LEFT_30, nil, nil },
    { "Firefox",   nil, nil, LEFT_30, nil, nil },
    { "Discord",   nil, nil, LEFT_30, nil, nil },
    { "Logic Pro", nil, nil, RIGHT_70, nil, nil },
    { "Mail",      nil, nil, LEFT_30, nil, nil },
    { "Messages",  nil, nil, LEFT_30, nil, nil },
    { "Notion",    nil, nil, LEFT_30, nil, nil },
    { "Safari",    nil, nil, LEFT_30, nil, nil },
    { "Slack",     nil, nil, LEFT_30, nil, nil },
    { "Spotify",   nil, nil, LEFT_30, nil, nil },
    { "Terminal",  nil, nil, RIGHT_70, nil, nil },
    { "kitty",     nil, nil, RIGHT_70, nil, nil },
    { "zoom.us",   nil, nil, LEFT_30, nil, nil },
}

-- |[][  ][]|
local LAYOUT_SECONDARY = {
    -- left
    { "Safari",    nil, nil, LEFT_30, nil, nil },
    { "Chromium",  nil, nil, LEFT_30, nil, nil },
    { "Firefox",   nil, nil, LEFT_30, nil, nil },
    { "Notion",    nil, nil, LEFT_30, nil, nil },
    { "Spotify",   nil, nil, LEFT_30, nil, nil },
    { "Calendar",  nil, nil, LEFT_30, nil, nil },

    -- center
    { "Terminal",  nil, nil, CENTER_60, nil, nil },
    { "kitty",     nil, nil, CENTER_60, nil, nil },
    { "Logic Pro", nil, nil, CENTER_60, nil, nil },
    { "zoom.us",   nil, nil, CENTER_60, nil, nil },

    -- right
    { "Discord",   nil, nil, RIGHT_30, nil, nil },
    { "Mail",      nil, nil, RIGHT_30, nil, nil },
    { "Messages",  nil, nil, RIGHT_30, nil, nil },
    { "Slack",     nil, nil, RIGHT_30, nil, nil },
}

-- |  [   ]  |
local LAYOUT_CENTERED = {
    { "Calendar",  nil, nil, CENTER_66, nil, nil },
    { "Chromium",  nil, nil, CENTER_66, nil, nil },
    { "Firefox",   nil, nil, CENTER_66, nil, nil },
    { "Discord",   nil, nil, CENTER_66, nil, nil },
    { "Logic Pro", nil, nil, CENTER_66, nil, nil },
    { "Mail",      nil, nil, CENTER_66, nil, nil },
    { "Messages",  nil, nil, CENTER_66, nil, nil },
    { "Notion",    nil, nil, CENTER_66, nil, nil },
    { "Safari",    nil, nil, CENTER_66, nil, nil },
    { "Slack",     nil, nil, CENTER_66, nil, nil },
    { "Spotify",   nil, nil, CENTER_66, nil, nil },
    { "Terminal",  nil, nil, CENTER_66, nil, nil },
    { "kitty",     nil, nil, CENTER_66, nil, nil },
    { "zoom.us",   nil, nil, CENTER_66, nil, nil },
}

-- multi-display layout; not currently using this
local function twoDisplayLayout()
    local display_primary = hs.screen.allScreens()[1]:name()
    local display_secondary = hs.screen.allScreens()[1]:name()

    -- if multiple displays are attatched, re-assign secondary display
    local num_screens = #hs.screen.allScreens()
    if num_screens > 1 then
        display_secondary = hs.screen.allScreens()[2]:name()
    end

    local layout = {
        { "Safari",   nil, display_primary, hs.layout.maximized, nil, nil },
        { "Notion",   nil, display_primary, hs.layout.maximized, nil, nil },
        { "kitty",    nil, display_primary, hs.layout.maximized, nil, nil },
        { "Terminal", nil, display_primary, hs.layout.maximized, nil, nil },
        { "Notion",   nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Spotify",  nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Slack",    nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Discord",  nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Messages", nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Calendar", nil, display_secondary, hs.layout.maximized, nil, nil },
        { "Mail",     nil, display_secondary, hs.layout.maximized, nil, nil },
    }

    hs.layout.apply(layout)
end

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
    hs.layout.apply(LAYOUT_PRIMARY)
end)

hs.hotkey.bind({ "cmd", "ctrl" }, "2", function()
    hs.layout.apply(LAYOUT_CENTERED)
end)

hs.hotkey.bind({ "cmd", "ctrl" }, "3", function()
    hs.layout.apply(LAYOUT_SECONDARY)
end)
