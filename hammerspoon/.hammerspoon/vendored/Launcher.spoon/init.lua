--- === Launcher ===
--- Seal's plugin engine with a native glass-backed chooser.
--- Derived from Hammerspoon/Spoons Seal (MIT), by Chris Jones and contributors.
local chooser = require("modules.chooser")

local obj = {
    name = "Launcher",
    version = "0.1",
    author = "Chris Jones <cmsj@tenshu.net> and contributors",
    homepage = "https://github.com/Hammerspoon/Spoons",
    license = "MIT - https://opensource.org/licenses/MIT",
    plugins = {},
    commands = {},
    queryChangedTimerDuration = 0.02,
    spoonPath = hs.spoons.scriptPath(),
}
obj.plugin_search_paths = {
    hs.configdir .. "/launcher_plugins",
    hs.configdir .. "/seal_plugins",
    obj.spoonPath,
}

function obj:refreshCommandsForPlugin(name)
    local plugin = self.plugins[name]
    for command, info in pairs(self.commands) do
        if info.plugin == plugin.__name then
            self.commands[command] = nil
        end
    end
    for command, info in pairs(plugin.commands and plugin:commands() or {}) do
        self.commands[command] = info
    end
    return self
end

function obj:refreshAllCommands()
    for name in pairs(self.plugins) do
        self:refreshCommandsForPlugin(name)
    end
    return self
end

function obj:loadPluginFromFile(name, path)
    local chunk = loadfile(path)
    if not chunk then
        return nil
    end
    local plugin = chunk()
    -- Preserve the upstream plugin contract and stored settings namespaces.
    plugin.seal = self
    plugin.launcher = self
    self.plugins[name] = plugin
    self:refreshCommandsForPlugin(name)
    return self
end

function obj:loadPlugins(names)
    if not self.chooser then
        self.chooser = chooser
            .new(self.completionCallback)
            :choices(self.choicesCallback)
            :queryChangedCallback(self.queryChangedCallback)
            :invalidCallback(function(choice)
                if choice.type == "plugin_cmd" then
                    self.chooser:query(choice.cmd .. " ")
                end
            end)
    end
    for _, name in ipairs(names) do
        if not self.plugins[name] then
            for _, directory in ipairs(self.plugin_search_paths) do
                if self:loadPluginFromFile(name, directory .. "/seal_" .. name .. ".lua") then
                    break
                end
            end
            assert(self.plugins[name], "Launcher plugin not found: " .. name)
        end
    end
    return self
end

function obj:bindHotkeys(mapping)
    for _, action in ipairs({ "show", "toggle" }) do
        local field = "hotkey_" .. action
        if self[field] then
            self[field]:delete()
            self[field] = nil
        end
        if mapping[action] then
            self[field] = hs.hotkey.new(mapping[action][1], mapping[action][2], function()
                self[action](self)
            end)
        end
    end
    return self
end

function obj:start()
    for _, field in ipairs({ "hotkey_show", "hotkey_toggle" }) do
        if self[field] then
            self[field]:enable()
        end
    end
    return self
end

function obj:stop()
    if self.queryChangedTimer then
        self.queryChangedTimer:stop()
    end
    if self.chooser then
        self.chooser:hide()
    end
    for _, field in ipairs({ "hotkey_show", "hotkey_toggle" }) do
        if self[field] then
            self[field]:disable()
        end
    end
    return self
end

function obj:show(query)
    if query ~= nil then
        self.chooser:query(query)
    end
    self.chooser:show()
    return self
end

function obj:toggle(query)
    if self.chooser:isVisible() then
        self.chooser:hide()
    else
        self:show(query)
    end
    return self
end

function obj.completionCallback(choice)
    if not choice then
        return
    end
    for _, plugin in pairs(obj.plugins) do
        if plugin.__name == choice.plugin then
            plugin.completionCallback(choice)
            break
        end
    end
end

function obj.choicesCallback()
    local query = obj.chooser and obj.chooser:query() or ""
    local command, arguments = query:match("^%s*(%S+)%s*(.*)$")
    if not command then
        return {}
    end
    local choices = {}
    local function append(results)
        for _, choice in ipairs(results or {}) do
            choices[#choices + 1] = choice
        end
    end
    for _, info in pairs(obj.commands) do
        if command:lower() == info.cmd:lower() then
            -- Upstream plugins use this sentinel for an empty command argument.
            append(info.fn(arguments == "" and ".*" or arguments))
        end
    end
    for _, plugin in pairs(obj.plugins) do
        local bare = plugin:bare()
        if bare then
            append(bare(query))
        end
    end
    if arguments == "" then
        for name, info in pairs(obj.commands) do
            if name:lower():find(command:lower(), 1, true) then
                choices[#choices + 1] = {
                    text = info.name,
                    subText = info.description,
                    type = "plugin_cmd",
                    cmd = info.cmd,
                    valid = false,
                }
            end
        end
    end
    table.sort(choices, function(a, b)
        return tostring(a.text):lower() < tostring(b.text):lower()
    end)
    return choices
end

function obj.queryChangedCallback()
    if obj.queryChangedTimer then
        obj.queryChangedTimer:stop()
    end
    obj.queryChangedTimer = hs.timer.doAfter(obj.queryChangedTimerDuration, function()
        if obj.chooser:isVisible() then
            obj.chooser:refreshChoicesCallback()
        end
    end)
end

return obj
