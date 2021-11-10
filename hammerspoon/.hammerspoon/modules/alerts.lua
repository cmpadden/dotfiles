--------------------------------------------------------------------------------
--                                Bound Alerts                                --
--------------------------------------------------------------------------------

local obj = {}

local helpers = require("modules.helpers")

function obj.alertCurrentTrack()
    hs.spotify.displayCurrentTrack()
end

function obj.alertSystemInformation()
    local attrs = {}
    attrs[#attrs + 1] = {
        name = "System Time",
        value = os.date("%A, %B %d, %Y %X"),
    }
    attrs[#attrs + 1] = {
        name = "Battery Capacity",
        value = hs.battery.capacity() / hs.battery.maxCapacity() * 100,
    }
    attrs[#attrs + 1] = {
        name = "Caffeine",
        value = tostring(hs.caffeinate.get("displayIdle")),
    }
    helpers:show("System Information", attrs, helpers.styles.success)
end

function obj.init()
    hs.hotkey.bind(HYPER, "2", obj.alertCurrentTrack)
    hs.hotkey.bind(HYPER, "x", obj.alertSystemInformation)
end

return obj
