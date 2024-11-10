local obj = {}

function obj:get_asset(filename)
    return hs.image.imageFromPath(hs.configdir .. "/assets/" .. filename)
end

-- icons were sourced from heroicons.dev and converted to PNGs using
-- `svgexport` (eg. svgexport assets/ban.svg assets/ban.png 50:50)
obj.assets = {
    logo = obj:get_asset("logo.png"),
    check = obj:get_asset("heroicons-mini/check-circle.png"),
    x = obj:get_asset("heroicons-mini/x-circle.png"),
    bolt = obj:get_asset("heroicons-mini/bolt.png"),
    bolt_slash = obj:get_asset("heroicons-mini/bolt-slash.png"),
}

obj.palette = {
    white = "#FFFFFF",
    black = "#000000",
    warn = "#FFF59D",
    success = "#F6FCDF",
    error = "#FFCDD2",
}

obj.styles = {
    info = {
        fillColor = { hex = obj.palette.white, alpha = 1.00 },
        textColor = { hex = obj.palette.black },
        strokeWidth = 0,
        radius = 0,
        padding = 16,
    },
    success = {
        fillColor = { hex = obj.palette.success, alpha = 1.00 },
        textColor = { hex = obj.palette.black },
        strokeWidth = 0,
        radius = 0,
        padding = 16,
    },
    warn = {
        fillColor = { hex = obj.palette.warn, alpha = 1.00 },
        textColor = { hex = obj.palette.black },
        strokeWidth = 0,
        radius = 0,
        padding = 16,
    },
    error = {
        fillColor = { hex = obj.palette.error, alpha = 1.00 },
        textColor = { hex = obj.palette.black },
        strokeWidth = 0,
        radius = 0,
        padding = 16,
    },
}

string.rpad = function(str, len)
    return str .. string.rep(" ", len - #str)
end

string.lpad = function(str, len)
    return string.rep(" ", len - #str) .. str
end

--- Center text with whitespace resulting in a string with total length of `width`.
string.center = function(str, width)
    if #str > width then
        return str
    end
    local padding_width = math.ceil((width - #str) / 2)
    local padding = string.rep(" ", padding_width)
    return padding .. str .. padding
end

--- Displays alert with `title` and pairs of `attributes`
---
--- Parameters:
--- * title     - Title message of alert
--- * attributes - Key-value pairs of attributes to present in body of alert
function obj:show(title, attributes, style, logo)
    style = style or obj.styles.info
    local lines = { title }
    if not (attributes == nil) then
        lines[#lines + 1] = string.rep("-", 80)
        for i = 1, #attributes do
            lines[#lines + 1] = string.rpad(attributes[i].name, 30) .. ": " .. attributes[i].value
        end
    end
    hs.alert.showWithImage(table.concat(lines, "\n"), logo, style)
end

function obj:show_centered(title, style, logo, width)
    local text = string.center(title, width)
    obj:show(text, nil, style, logo)
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
