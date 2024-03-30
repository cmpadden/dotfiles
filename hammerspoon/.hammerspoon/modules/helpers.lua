local obj = {}

function obj:get_asset(filename)
    return hs.image.imageFromPath(hs.configdir .. "/assets/" .. filename)
end

-- icons were sourced from heroicons.dev and converted to PNGs using
-- `svgexport` (eg. svgexport assets/ban.svg assets/ban.png 50:50)
obj.assets = {
    logo = obj:get_asset("logo.png"),
    check = obj:get_asset("check.png"),
    ban = obj:get_asset("ban.png"),
}

obj.styles = {
    info = { fillColor = { hex = "#FFFFFF", alpha = 0.95 } },
    success = { fillColor = { hex = "#DCEDC8", alpha = 0.95 } },
    warn = { fillColor = { hex = "#FFF59D", alpha = 0.95 } },
    error = { fillColor = { hex = "#FFCDD2", alpha = 0.95 } },
}

string.rpad = function(str, len)
    return str .. string.rep(" ", len - #str)
end

string.lpad = function(str, len)
    return string.rep(" ", len - #str) .. str
end

--- Displays alert with `title` and pairs of `attributes`
---
--- Parameters:
--- * title     - Title message of alert
--- * attributs - Key-value pairs of attributes to present in body of alert
function obj:show(title, attributes, style, logo)
    style = style or obj.styles.info
    logo = logo or obj.assets.logo
    local lines = { title }
    if not (attributes == nil) then
        lines[#lines + 1] = string.rep("-", 80)
        for i = 1, #attributes do
            lines[#lines + 1] = string.rpad(attributes[i].name, 30) .. ": " .. attributes[i].value
        end
    end
    hs.alert.showWithImage(table.concat(lines, "\n"), logo, style)
end

function obj:info(msg)
    hs.alert.showWithImage(msg, obj.assets.logo, obj.styles.info)
end

function obj:success(msg)
    hs.alert.showWithImage(msg, obj.assets.logo, obj.styles.success)
end

function obj:warn(msg)
    hs.alert.showWithImage(msg, obj.assets.logo, obj.styles.warn)
end

function obj:error(msg)
    hs.alert.showWithImage(msg, obj.assets.logo, obj.styles.error)
end

-- Sleep for `ms` milliseconds.
--
-- http://lua-users.org/wiki/SleepFunction
function obj:sleep(ms)
    os.execute("sleep " .. tonumber(ms) / 1000)
end

function obj:led_blinker()
    for _ = 1, 10 do
        obj:sleep(100)
        hs.hid.led.set("caps", true)
        obj:sleep(100)
        hs.hid.led.set("caps", false)
    end
end

-- function obj.tty()
--     local handle, err = io.popen("tty")
--     local output = handle:read("*all")
--     handle:close()
--     return output
-- end

return obj
