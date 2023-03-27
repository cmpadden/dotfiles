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

WINDOW_CENTERED = hs.geometry({ x = 0.2, y = 0.025, w = 0.6, h = 0.95 })

PADDING_H = 0.1
PADDING_V = 0.02
PADDING_C = 0.005
WINDOW_SPLIT = 0.375

SPLIT_LEFT = hs.geometry({
    x = 0.5 - (PADDING_C / 2) - WINDOW_SPLIT,
    y = PADDING_V,
    w = WINDOW_SPLIT,
    h = 1 - 2 * PADDING_V,
})
SPLIT_RIGHT = hs.geometry({
    x = 0.5 + (PADDING_C / 2),
    y = PADDING_V,
    w = WINDOW_SPLIT,
    h = 1 - 2 * PADDING_V,
})

local LAYOUTS = {

    -- Primary layout: |[       ]|
    [1] = {
        { "Calendar", nil, nil, hs.layout.maximized, nil, nil },
        { "Chromium", nil, nil, hs.layout.maximized, nil, nil },
        { "Discord", nil, nil, hs.layout.maximized, nil, nil },
        { "Firefox", nil, nil, hs.layout.maximized, nil, nil },
        { "Google Chrome", nil, nil, hs.layout.maximized, nil, nil },
        { "Brave Browser", nil, nil, hs.layout.maximized, nil, nil },
        { "Logic Pro", nil, nil, hs.layout.maximized, nil, nil },
        { "Mail", nil, nil, hs.layout.maximized, nil, nil },
        { "Messages", nil, nil, hs.layout.maximized, nil, nil },
        { "Notes", nil, nil, hs.layout.maximized, nil, nil },
        { "Notion", nil, nil, hs.layout.maximized, nil, nil },
        { "Safari", nil, nil, hs.layout.maximized, nil, nil },
        { "Slack", nil, nil, hs.layout.maximized, nil, nil },
        { "Spotify", nil, nil, hs.layout.maximized, nil, nil },
        { "Terminal", nil, nil, hs.layout.maximized, nil, nil },
        { "kitty", nil, nil, hs.layout.maximized, nil, nil },
        { "zoom.us", nil, nil, hs.layout.maximized, nil, nil },
    },

    -- Secondary layout: | [  ][  ] |
    [2] = {

        -- left
        { "Terminal", nil, nil, SPLIT_LEFT, nil, nil },
        { "kitty", nil, nil, SPLIT_LEFT, nil, nil },

        -- right
        { "Brave Browser", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Calendar", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Chromium", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Discord", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Firefox", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Google Chrome", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Logic Pro", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Mail", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Messages", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Notes", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Notion", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Safari", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Slack", nil, nil, SPLIT_RIGHT, nil, nil },
        { "Spotify", nil, nil, SPLIT_RIGHT, nil, nil },
        { "zoom.us", nil, nil, SPLIT_RIGHT, nil, nil },
    },

    -- Centered layout: |  [   ]  |
    [3] = {
        { "Calendar", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Chromium", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Google Chrome", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Firefox", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Discord", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Logic Pro", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Mail", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Messages", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Notion", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Notes", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Safari", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Slack", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Spotify", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Terminal", nil, nil, WINDOW_CENTERED, nil, nil },
        { "kitty", nil, nil, WINDOW_CENTERED, nil, nil },
        { "zoom.us", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Figma", nil, nil, WINDOW_CENTERED, nil, nil },
        { "Brave Browser", nil, nil, WINDOW_CENTERED, nil, nil },
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

local function application_callback(app_name, event_type, app)
    -- apply layout on application launch
    if event_type == hs.application.watcher.launched then
        -- workaround: wait for application to be loaded
        while app:mainWindow() == nil do
            -- app:mainWindow() will be `nil` until fully loaded
        end

        -- apply application-specific layout given current `obj.layout`
        for _, window in ipairs(LAYOUTS[obj.layout]) do
            if window[1] == app:name() then
                hs.alert("[" .. obj.layout .. "] " .. app_name)
                app:mainWindow():moveToUnit(window[4])
                break
            end
        end
    end
end

function obj:set_layout(layout)
    self.layout = layout
    hs.layout.apply(LAYOUTS[layout])
    hs.alert("Set Window Layout: " .. layout)
end

-- Initialize window layout state, and setup application watcher
function obj:init()
    -- determine # of displays
    self.num_displays = #hs.screen.allScreens()
    hs.alert("# displays: " .. self.num_displays)

    -- set default window layout
    self.layout = 1

    -- initialize application watcher to automatically apply layout to new windows
    self.application_watcher = hs.application.watcher.new(application_callback)
    self.application_watcher:start()
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
