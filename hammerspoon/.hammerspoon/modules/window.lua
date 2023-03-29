----------------------------------------------------------------------------------------
--                                 Window Management                                  --
----------------------------------------------------------------------------------------

-- References
-- https://www.hammerspoon.org/go/#winlayout
-- https://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html
-- https://www.hammerspoon.org/Spoons/WindowScreenLeftAndRight.html

local obj = {}
obj.__index = obj

obj.name = "Window Management"
obj.version = "1.0.0"

----------------------------------------------------------------------------------------
--                                      Helpers                                       --
----------------------------------------------------------------------------------------

PADDING_H = 0.1
PADDING_V = 0.02
PADDING_C = 0.005
WINDOW_WIDTH_SPLIT = 0.375
WINDOW_WIDTH_CENTERED = 0.6

-- [  [    ]  ]
RECT_CENTER = hs.geometry({
    x = (1 - WINDOW_WIDTH_CENTERED) / 2,
    y = PADDING_V,
    w = WINDOW_WIDTH_CENTERED,
    h = 1 - 2 * PADDING_V,
})

-- [  [ ]     ]
RECT_LEFT = hs.geometry({
    x = 0.5 - (PADDING_C / 2) - WINDOW_WIDTH_SPLIT,
    y = PADDING_V,
    w = WINDOW_WIDTH_SPLIT,
    h = 1 - 2 * PADDING_V,
})

-- [     [ ]  ]
RECT_RIGHT = hs.geometry({
    x = 0.5 + (PADDING_C / 2),
    y = PADDING_V,
    w = WINDOW_WIDTH_SPLIT,
    h = 1 - 2 * PADDING_V,
})

-- [[]        ]
RECT_MINI_LEFT = {
    x = PADDING_V,
    y = PADDING_V,
    w = ((1 - WINDOW_WIDTH_CENTERED) / 2) - 2 * PADDING_V,
    h = 1 - 2 * PADDING_V,
}

-- [        []]
RECT_MINI_RIGHT = {
    x = 1 - ((1 - WINDOW_WIDTH_CENTERED) / 2) + PADDING_V,
    y = PADDING_V,
    w = ((1 - WINDOW_WIDTH_CENTERED) / 2) - 2 * PADDING_V,
    h = 1 - 2 * PADDING_V,
}

LAYOUTS = {
    -- Primary layout: |[       ]|
    [1] = {
        ["Brave Browser"] = hs.layout.maximized,
        ["Calendar"] = hs.layout.maximized,
        ["Chromium"] = hs.layout.maximized,
        ["Discord"] = hs.layout.maximized,
        ["Firefox"] = hs.layout.maximized,
        ["Google Chrome"] = hs.layout.maximized,
        ["Logic Pro"] = hs.layout.maximized,
        ["Mail"] = hs.layout.maximized,
        ["Messages"] = hs.layout.maximized,
        ["Notes"] = hs.layout.maximized,
        ["Notion"] = hs.layout.maximized,
        ["Safari"] = hs.layout.maximized,
        ["Slack"] = hs.layout.maximized,
        ["Spotify"] = hs.layout.maximized,
        ["Terminal"] = hs.layout.maximized,
        ["kitty"] = hs.layout.maximized,
        ["zoom.us"] = hs.layout.maximized,
    },
    -- Secondary layout: | [  ][  ] |
    [2] = {
        -- left
        ["Terminal"] = RECT_LEFT,
        ["kitty"] = RECT_LEFT,

        -- right
        ["Brave Browser"] = RECT_RIGHT,
        ["Calendar"] = RECT_RIGHT,
        ["Chromium"] = RECT_RIGHT,
        ["Discord"] = RECT_RIGHT,
        ["Firefox"] = RECT_RIGHT,
        ["Google Chrome"] = RECT_RIGHT,
        ["Logic Pro"] = RECT_RIGHT,
        ["Mail"] = RECT_RIGHT,
        ["Messages"] = RECT_RIGHT,
        ["Notes"] = RECT_RIGHT,
        ["Notion"] = RECT_RIGHT,
        ["Safari"] = RECT_RIGHT,
        ["Slack"] = RECT_RIGHT,
        ["Spotify"] = RECT_RIGHT,
        ["zoom.us"] = RECT_RIGHT,
    },
    -- Centered layout: |  [   ]  |
    [3] = {
        ["Brave Browser"] = RECT_CENTER,
        ["Calendar"] = RECT_CENTER,
        ["Chromium"] = RECT_CENTER,
        ["Discord"] = RECT_CENTER,
        ["Figma"] = RECT_CENTER,
        ["Firefox"] = RECT_CENTER,
        ["Google Chrome"] = RECT_CENTER,
        ["Logic Pro"] = RECT_CENTER,
        ["Mail"] = RECT_CENTER,
        ["Messages"] = RECT_CENTER,
        ["Notes"] = RECT_CENTER,
        ["Notion"] = RECT_CENTER,
        ["Safari"] = RECT_CENTER,
        ["Slack"] = RECT_CENTER,
        ["Spotify"] = RECT_CENTER,
        ["Terminal"] = RECT_CENTER,
        ["kitty"] = RECT_CENTER,
        ["zoom.us"] = RECT_CENTER,
    },
}

-- multi-display layout; not currently using this
local function two_display_layout()
    local display_primary = hs.screen.allScreens()[1]:name()
    local display_secondary = hs.screen.allScreens()[1]:name()

    -- if multiple displays are attatched, re-assign secondary display
    local num_screens = #hs.screen.allScreens()
    if num_screens > 1 then
        display_secondary = hs.screen.allScreens()[2]:name()
    end

    local layout = {
        { "Safari", nil, display_primary, hs.layout.maximized, nil, nil },
        { "Notion", nil, display_primary, hs.layout.maximized, nil, nil },
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

    hs.layout.apply(layout)
end

-- Apply application-specific layout given active `obj.layout`
local function resize_window(window, app_name)
    if LAYOUTS[obj.layout][app_name] ~= nil then
        window:moveToUnit(LAYOUTS[obj.layout][app_name])
    else
        -- picture-in-picture window
        window:moveToUnit(RECT_MINI_RIGHT)
    end
end

-- NOTE: previously, the `set_layout` method leveraged `hs.layout.apply`, however, this
-- was removed as it would iterate over all application layout definitions in the table,
-- and was less performant than only applying layouts to specific windows via
-- `hs.window.filter.default`.
function obj:set_layout(layout)
    self.layout = layout
    local active_layout = LAYOUTS[layout]

    local active_windows = hs.window.filter.default:getWindows()
    for _, w in ipairs(active_windows) do
        local app_name = w:application():name()

        if active_layout[app_name] ~= nil then
            w:moveToUnit(active_layout[app_name])
        end
    end
end

-- Initialize window layout state, and setup application watcher
function obj:init()
    -- TODO: support multi-display layouts
    -- self.num_displays = #hs.screen.allScreens()
    -- hs.alert("# displays: " .. self.num_displays)

    -- set default window layout
    self.layout = 3

    -- NOTE: this will resize windows back to their expected location on move or resize,
    -- this prevents the user from moving a window, and should instead be implemented
    -- using some form of a _floating_ window.
    -- hs.window.filter.default:subscribe(hs.window.filter.windowMoved, resize_window)

    hs.window.filter.default:subscribe(hs.window.filter.windowCreated, resize_window)

    hs.window.animationDuration = 0

    hs.hotkey.bind({ "cmd", "ctrl" }, "1", function()
        obj:set_layout(1)
    end)

    hs.hotkey.bind({ "cmd", "ctrl" }, "2", function()
        obj:set_layout(2)
    end)

    hs.hotkey.bind({ "cmd", "ctrl" }, "3", function()
        obj:set_layout(3)
    end)
end

return obj
