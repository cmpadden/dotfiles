--------------------------------------------------------------------------------
--                                Bound Alerts                                --
--------------------------------------------------------------------------------

local helpers = require("modules.helpers")

hs.hotkey.bind(HYPER, "9", function()
    hs.spotify.displayCurrentTrack()
end)

hs.hotkey.bind(HYPER, "x", function()
    local attrs = {}
    attrs[#attrs + 1] = {
        name = "System Time",
        value = os.date("%A, %B %d, %Y %X"),
    }
    local battery_capacity = hs.battery.capacity()
    local max_battery_capacity = hs.battery.maxCapacity()
    if not (battery_capacity == nil and max_battery_capacity == nil) then
        attrs[#attrs + 1] = {
            name = "Battery Capacity",
            value = battery_capacity / max_battery_capacity * 100,
        }
    end
    attrs[#attrs + 1] = {
        name = "Caffeine",
        value = tostring(hs.caffeinate.get("displayIdle")),
    }
    helpers:show("System Information", attrs, helpers.styles.success)
end)
