--------------------------------------------------------------------------------
--                                Bound Alerts                                --
--------------------------------------------------------------------------------

local helpers = require("modules.helpers")

hs.hotkey.bind(HYPER, "2", function()
    hs.spotify.displayCurrentTrack()
end)

hs.hotkey.bind(HYPER, "x", function()
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
end)
