--- Persistent layout selection and per-layout window geometries.
--
-- The JSON object has an optional active_layout field alongside the legacy
-- layout-index keys. Geometry keys are strings on disk and numbers in memory.

local State = {}
State.__index = State

local M = {}

function M.new(path)
    return setmetatable({ path = path, data = {} }, State)
end

local function layer(self, layout)
    if self.data[layout] == nil then
        self.data[layout] = {}
    end
    return self.data[layout]
end

--- The most recent geometry index for a window in a layout (default 1).
function State:get_index(layout, window_key)
    return layer(self, layout)[window_key] or 1
end

function State:set_index(layout, window_key, index)
    layer(self, layout)[window_key] = index
end

--- Remove a window's entries from every layout.
function State:remove_window(window_key)
    for _, windows in pairs(self.data) do
        windows[window_key] = nil
    end
end

--- Table of window_key -> geometry_index for a layout, or nil.
function State:layout_state(layout)
    return self.data[layout]
end

--- Drop entries for windows missing from the `active_window_keys` set.
function State:cleanup(active_window_keys)
    for _, windows in pairs(self.data) do
        for window_key in pairs(windows) do
            if not active_window_keys[window_key] then
                windows[window_key] = nil
            end
        end
    end
end

function State:save()
    local raw = { active_layout = self.active_layout }
    for layout, windows in pairs(self.data) do
        raw[tostring(layout)] = windows
    end
    if hs.json.write(raw, self.path, true, true) then
        return true
    end
    return false, string.format("wm: could not write state to %s", self.path)
end

function State:load()
    local raw = hs.json.read(self.path)
    if type(raw) ~= "table" then
        return false, string.format("wm: could not read state from %s", self.path)
    end

    local data = {}
    for layout, windows in pairs(raw) do
        if layout ~= "active_layout" and type(windows) == "table" then
            local entries = {}
            for window_key, index in pairs(windows) do
                local numeric_index = tonumber(index)
                if numeric_index then
                    entries[window_key] = numeric_index
                end
            end
            data[tonumber(layout) or layout] = entries
        end
    end
    self.data = data
    self.active_layout = tonumber(raw.active_layout)
    return true
end

return M
