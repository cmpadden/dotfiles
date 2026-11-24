local island_hud = require("modules.island_hud")
local obj = {}

function obj.bind(modifiers, key, options)
    local position = (options or {}).position or "bottom"
    assert(
        position == "top" or position == "bottom",
        'Caffeine HUD position must be "top" or "bottom"'
    )
    return hs.hotkey.bind(modifiers, key, function()
        hs.caffeinate.toggle("displayIdle")
        local enabled = hs.caffeinate.get("displayIdle")
        island_hud.show(enabled and "Caffeine Enabled" or "Caffeine Disabled", position)
    end)
end

return obj
