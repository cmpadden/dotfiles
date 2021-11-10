--------------------------------------------------------------------------------
--                                  Watchers                                  --
--------------------------------------------------------------------------------

local obj = {}

local alerts = require("modules.alerts")
local helpers = require("modules.helpers")

-- automatically maximize launched application main window
function obj.cbApplication(appName, eventType, appObject)
    if eventType == hs.application.watcher.launched then
        hs.alert.show("Application Launched: " .. appName)
        appObject:mainWindow():moveToUnit(hs.layout.maximized)
    end
end

function obj.cbDownloads(files, flagTables)
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

function obj.cbCaffeine(type)
    -- if type == hs.caffeinate.watcher.screensDidLock then
    --     hs.alert.showWithImage('LOCKED', LOGO)
    -- end
    if type == hs.caffeinate.watcher.screensDidUnlock then
        alerts.alertSystemInformation()
    end
end

function obj.init()
    local _ = hs.application.watcher.new(obj.cbApplication):start()
    local _ = hs.pathwatcher.new(os.getenv("HOME") .. "/Downloads/", obj.cbDownloads):start()
    local _ = hs.caffeinate.watcher.new(obj.cbCaffeine):start()
end

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

return obj
