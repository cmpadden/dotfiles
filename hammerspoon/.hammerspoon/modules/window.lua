-------------------------------------------------------------------------------------------------------------------------
--                                                  Window Management                                                  --
-------------------------------------------------------------------------------------------------------------------------

-- References
-- https://www.hammerspoon.org/go/#winlayout
-- https://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html
-- https://www.hammerspoon.org/Spoons/WindowScreenLeftAndRight.html

local obj = {}
obj.__index = obj

obj.name = "Window Management"
obj.version = "1.0.0"

-------------------------------------------------------------------------------------------------------------------------
--                                                       Helpers                                                       --
-------------------------------------------------------------------------------------------------------------------------

CENTER_60       = hs.geometry({ x = 0.2, y = 0.0, w = 0.6, h = 1.0 })
CENTER_66       = hs.geometry({ x = 0.1666, y = 0, w = 0.6666, h = 1 })
LEFT_30         = hs.geometry({ x = 0.0, y = 0.0, w = 0.3, h = 1.0 })
LEFT_70         = hs.geometry({ x = 0.0, y = 0.0, w = 0.7, h = 1.0 })
RIGHT_30        = hs.geometry({ x = 0.70, y = 0.0, w = 0.3, h = 1.0 })
RIGHT_70        = hs.geometry({ x = 0.3, y = 0.0, w = 0.7, h = 1.0 })
FULL            = hs.geometry({ x = 0, y = 0, w = 1, h = 1 })

LEFT_50         = hs.geometry({ x = 0.0, y = 0.0, w = 0.5, h = 1.0 })
RIGHT_50        = hs.geometry({ x = 0.50, y = 0.0, w = 0.5, h = 1.0 })

LEFT_30_OFFSET  = hs.geometry({ x = 0.1, y = 0.0, w = 0.4, h = 1.0 })
RIGHT_50_OFFSET = hs.geometry({ x = 0.5, y = 0.0, w = 0.4, h = 1.0 })

-- |[       ]|
local LAYOUT_PRIMARY = {
    { "Calendar",      nil, nil, hs.layout.maximized, nil, nil },
    { "Chromium",      nil, nil, hs.layout.maximized, nil, nil },
    { "Discord",       nil, nil, hs.layout.maximized, nil, nil },
    { "Firefox",       nil, nil, hs.layout.maximized, nil, nil },
    { "Google Chrome", nil, nil, hs.layout.maximized, nil, nil },
    { "Brave Browser", nil, nil, hs.layout.maximized, nil, nil },
    { "Logic Pro",     nil, nil, hs.layout.maximized, nil, nil },
    { "Mail",          nil, nil, hs.layout.maximized, nil, nil },
    { "Messages",      nil, nil, hs.layout.maximized, nil, nil },
    { "Notes",         nil, nil, hs.layout.maximized, nil, nil },
    { "Notion",        nil, nil, hs.layout.maximized, nil, nil },
    { "Safari",        nil, nil, hs.layout.maximized, nil, nil },
    { "Slack",         nil, nil, hs.layout.maximized, nil, nil },
    { "Spotify",       nil, nil, hs.layout.maximized, nil, nil },
    { "Terminal",      nil, nil, hs.layout.maximized, nil, nil },
    { "kitty",         nil, nil, hs.layout.maximized, nil, nil },
    { "zoom.us",       nil, nil, hs.layout.maximized, nil, nil },
}

-- | [  ][  ] |
local LAYOUT_SECONDARY = {

    -- left
    { "Terminal",      nil, nil, LEFT_30_OFFSET, nil, nil },
    { "kitty",         nil, nil, LEFT_30_OFFSET, nil, nil },

    -- right
    { "Brave Browser", nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Calendar",      nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Chromium",      nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Discord",       nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Firefox",       nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Google Chrome", nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Logic Pro",     nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Mail",          nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Messages",      nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Notes",         nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Notion",        nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Safari",        nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Slack",         nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "Spotify",       nil, nil, RIGHT_50_OFFSET, nil, nil },
    { "zoom.us",       nil, nil, RIGHT_50_OFFSET, nil, nil },
}

-- |  [   ]  |
local LAYOUT_CENTERED = {
    { "Calendar",      nil, nil, CENTER_60, nil, nil },
    { "Chromium",      nil, nil, CENTER_60, nil, nil },
    { "Google Chrome", nil, nil, CENTER_60, nil, nil },
    { "Firefox",       nil, nil, CENTER_60, nil, nil },
    { "Discord",       nil, nil, CENTER_60, nil, nil },
    { "Logic Pro",     nil, nil, CENTER_60, nil, nil },
    { "Mail",          nil, nil, CENTER_60, nil, nil },
    { "Messages",      nil, nil, CENTER_60, nil, nil },
    { "Notion",        nil, nil, CENTER_60, nil, nil },
    { "Notes",         nil, nil, CENTER_60, nil, nil },
    { "Safari",        nil, nil, CENTER_60, nil, nil },
    { "Slack",         nil, nil, CENTER_60, nil, nil },
    { "Spotify",       nil, nil, CENTER_60, nil, nil },
    { "Terminal",      nil, nil, CENTER_60, nil, nil },
    { "kitty",         nil, nil, CENTER_60, nil, nil },
    { "zoom.us",       nil, nil, CENTER_60, nil, nil },
    { "Figma",         nil, nil, CENTER_60, nil, nil },
    { "Brave Browser", nil, nil, CENTER_60, nil, nil },
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

-- enumeration of possible window layouts
local CENTERED, PRIMARY, SECONDARY = 1, 2, 3

-------------------------------------------------------------------------------------------------------------------------
--                                                       Module                                                        --
-------------------------------------------------------------------------------------------------------------------------

local function application_callback(app_name, event_type, app)
    if event_type == hs.application.watcher.launched then
        hs.alert("Launched " .. app_name)

        while app:mainWindow() == nil do
            -- app:mainWindow() will be `nil` until fully loaded
        end

        if obj.layout == CENTERED then
            app:mainWindow():moveToUnit(CENTER_66)
        elseif obj.layout == PRIMARY then
            app:mainWindow():moveToUnit(RIGHT_70)
        elseif obj.layout == SECONDARY then
            app:mainWindow():moveToUnit(CENTER_60)
        end
    end
end

-- Initialize window layout state, and setup application watcher
function obj:init()
    -- set default window layout
    self.layout = CENTERED

    -- initialize application watcher to automatically apply layout to new windows
    self.application_watcher = hs.application.watcher.new(application_callback)
    self.application_watcher:start()
    hs.window.animationDuration = 0


    hs.hotkey.bind({ "cmd", "ctrl" }, "1", function()
        self.layout = PRIMARY
        hs.layout.apply(LAYOUT_PRIMARY)
    end)

    hs.hotkey.bind({ "cmd", "ctrl" }, "2", function()
        self.layout = SECONDARY
        hs.layout.apply(LAYOUT_SECONDARY)
    end)

    hs.hotkey.bind({ "cmd", "ctrl" }, "3", function()
        self.layout = CENTERED
        hs.layout.apply(LAYOUT_CENTERED)
    end)
end

return obj
