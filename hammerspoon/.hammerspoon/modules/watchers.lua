--------------------------------------------------------------------------------
--                                  Watchers                                  --
--------------------------------------------------------------------------------

local helpers = require("modules.helpers")

-- local function application_callback(appName, eventType, app)
--     if eventType == hs.application.watcher.launched then
--         hs.alert.show("Application Launched: " .. appName)
--         while app:mainWindow() == nil do
--             -- app:mainWindow() will be `nil` until fully loaded
--         end
--         app:mainWindow():moveToUnit(hs.layout.maximized)
--     end
-- end
-- APPLICATION_WATCHER = hs.application.watcher.new(application_callback)
-- APPLICATION_WATCHER:start()

local function callback_pathwatcher(files, flagTables)
    local mods = {}
    for ix, file in pairs(files) do
        local events = {}
        for event, _ in pairs(flagTables[ix]) do
            events[#events + 1] = event
        end
        mods[#mods + 1] = {
            name = table.concat(events, ","),
            value = file,
        }
    end
    helpers:show("Downloads Updated", mods)
end
DOWNLOAD_WATCHER = hs.pathwatcher.new(os.getenv("HOME") .. "/Downloads/", callback_pathwatcher)
DOWNLOAD_WATCHER:start()

-- local function caffeine_callback(type)
--     if type == hs.caffeinate.watcher.screensDidLock then
--         hs.alert.show("Screen Lock Event")
--     elseif type == hs.caffeinate.watcher.screensDidUnlock then
--         hs.alert.show("Screen Unlock Event")
--     end
-- end
-- hs.caffeinate.watcher.new(caffeine_callback):start()


-- -- TODO - move to window management module, and automatically place windows on creation
-- local function screen_callback()
--     hs.alert.show("Screen Watcher Event")
--     -- if num_of_screens ~= #hs.screen.allScreens() then
--     -- autolayout.autoLayout()
--     -- num_of_screens = #hs.screen.allScreens()
--     -- end
-- end
-- SCREEN_WATCHER = hs.screen.watcher.new(screen_callback)
-- SCREEN_WATCHER:start()

--local function cbBattery()
--     local alert = string.format([[
--Battery Status
------------------------------------------
--Percentage     : %s
--Time Remaining : %s min.
--Time to Charge : %s min.
--Charging       : %s
--Amperage       : %s mAh
--Cycles         : %s]],
--    hs.battery.percentage(),
--    hs.battery.timeRemaining(),
--    hs.battery.timeToFullCharge(),
--    hs.battery.isCharging(),
--    hs.battery.amperage(),
--    hs.battery.cycles()
--    )
--    hs.alert.show(alert)
--end
--local _ = hs.battery.watcher.new(cbBattery):start()
