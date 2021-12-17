--------------------------------------------------------------------------------
--                                  Watchers                                  --
--------------------------------------------------------------------------------

-- automatically maximize launched application main window
local function cbApplication(appName, eventType, appObject)
    if eventType == hs.application.watcher.launched then
        hs.alert.show("Application Launched: " .. appName)
        appObject:mainWindow():moveToUnit(hs.layout.maximized)
        -- elseif (eventType == hs.application.watcher.activated) then
        --     hs.alert.show('Application Activated: ' .. appName)
    end
end
local _ = hs.application.watcher.new(cbApplication):start()

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
local _ = hs.pathwatcher.new(os.getenv("HOME") .. "/Downloads/", callback_pathwatcher):start()

local function caffeine_callback(type)
    -- if type == hs.caffeinate.watcher.screensDidLock then
    --     hs.alert.showWithImage('LOCKED', LOGO)
    -- end
    if type == hs.caffeinate.watcher.screensDidUnlock then
        alertSystemInfo()
    end
end
hs.caffeinate.watcher.new(caffeine_callback):start()

-- hs.screen.watcher.new(function()
--     hs.alert.show("Screen Watcher Event")
--     if num_of_screens ~= #hs.screen.allScreens() then
--       autolayout.autoLayout()
--       num_of_screens = #hs.screen.allScreens()
--     end
-- end):start()

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

