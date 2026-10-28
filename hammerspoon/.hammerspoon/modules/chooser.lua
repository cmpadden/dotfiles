-- Native, glass-backed subset of hs.chooser. Never replaces the global hs.chooser.
local M = {}
local Chooser = {}
Chooser.__index = Chooser
local instances = setmetatable({}, { __mode = "k" })
local log = hs.logger.new("chooser", "warning")

local function plain(value)
    if value == nil then
        return ""
    end
    if type(value) == "userdata" and value.getString then
        return value:getString()
    end
    return tostring(value)
end

function M.new(completion)
    local self = setmetatable({
        _completion = completion,
        _query = "",
        _placeholder = "Launcher",
        _rows = 8,
        _width = 42,
        _maxWidth = 640,
        _selected = 0,
        _session = 0,
        _revision = 0,
        _input = 0,
        _visible = false,
        _display = {},
        _source = {},
        _images = setmetatable({}, { __mode = "k" }),
    }, Chooser)
    instances[self] = true
    return self
end

-- hs.task:setInput discards unwritten bytes. Keep exactly one snapshot in flight,
-- acknowledge it from Swift, and coalesce pending updates to the latest full state.
function Chooser:_flush()
    if self._ready and not self._inflight and self._pending and self._task then
        local state = self._pending
        self._pending = nil
        self._inflight = true
        self._task:setInput(hs.json.encode(state) .. "\n")
    end
end

function Chooser:_update()
    self._revision = self._revision + 1
    local choices = {}
    for _, choice in ipairs(self._display) do
        local image
        if type(choice.image) == "userdata" then
            image = self._images[choice.image]
            if not image then
                local ok, encoded = pcall(function()
                    return choice.image:setSize({ w = 32, h = 32 }):encodeAsURLString()
                end)
                if ok then
                    image = encoded
                    self._images[choice.image] = image
                end
            end
        end
        choices[#choices + 1] =
            { text = plain(choice.text), subText = plain(choice.subText), image = image }
    end
    self._pending = {
        session = self._session,
        revision = self._revision,
        input = self._input,
        visible = self._visible,
        query = self._query,
        placeholder = self._placeholder,
        rows = self._rows,
        width = self._width,
        maxWidth = self._maxWidth,
        selected = self._selected,
        choices = choices,
        position = self._position,
    }
    self:_flush()
end

function Chooser:_didHide()
    local pending = self._hiding
    self._hiding = nil
    if not pending then
        return
    end
    if self._hideCallback then
        self._hideCallback()
    end
    if pending.complete and self._completion then
        self._completion(pending.choice)
    end
end

function Chooser:_receive(event)
    if event.event == "ready" then
        self._ready = true
        self:_flush()
        return
    elseif event.event == "ack" then
        self._inflight = false
        self:_flush()
        return
    end
    if event.session ~= self._session then
        return
    end
    if event.event == "hidden" and not self._visible then
        self:_didHide()
    elseif event.event == "shown" and self._visible then
        if self._showCallback then
            self._showCallback()
        end
    elseif self._visible then
        if event.event == "query" then
            self:_setQuery(event.query, event.input)
        elseif event.event == "cancel" then
            self:cancel()
        elseif event.revision == self._revision then
            if event.event == "selection" then
                self._selected = event.row
            elseif event.event == "select" and event.query == self._query then
                self:select(event.row)
            end
        end
    end
end

function Chooser:_start()
    if self._task then
        return true
    end
    local binary = hs.configdir .. "/native/.build/native-chooser"
    if not hs.fs.attributes(binary) then
        hs.showError("Build the native launcher first: make -C ~/.hammerspoon native")
        return false
    end
    local buffer = ""
    local task
    task = hs.task.new(binary, function(code, _, stderr)
        if self._task ~= task then
            return
        end
        self._task, self._ready, self._inflight = nil, false, false
        local was_visible = self._visible
        self._visible = false
        if code ~= 0 then
            log.w("Native chooser exited: " .. tostring(stderr))
        end
        if was_visible and not self._hiding then
            self._hiding = { complete = true }
        end
        self:_didHide()
    end, function(_, stdout, stderr)
        if self._task ~= task then
            return false
        end
        if stderr and stderr ~= "" then
            log.w(stderr)
        end
        buffer = buffer .. (stdout or "")
        while true do
            local newline = buffer:find("\n", 1, true)
            if not newline then
                break
            end
            local line = buffer:sub(1, newline - 1)
            buffer = buffer:sub(newline + 1)
            local ok, event = pcall(hs.json.decode, line)
            if ok and type(event) == "table" then
                -- A plugin callback must not permanently disable hs.task streaming.
                local delivered, err = xpcall(self._receive, debug.traceback, self, event)
                if not delivered then
                    log.w(err)
                end
            else
                log.w("Invalid native chooser event")
            end
        end
        return true
    end)
    self._task = task
    if not task or not task:start() then
        self._task = nil
        hs.showError(
            "Could not start the native launcher; rebuild with make -C ~/.hammerspoon native"
        )
        return false
    end
    return true
end

function Chooser:choices(source)
    self._source = source or {}
    return self:refreshChoicesCallback()
end

function Chooser:refreshChoicesCallback()
    local choices = self._source
    if type(choices) == "function" then
        local ok, result = xpcall(choices, debug.traceback)
        if not ok then
            log.w(result)
        end
        choices = ok and result or {}
    end
    self._display = {}
    for _, choice in ipairs(choices or {}) do
        local text = plain(choice.text)
        if self._searchSubText then
            text = text .. " " .. plain(choice.subText)
        end
        if type(self._source) == "function" or text:lower():find(self._query:lower(), 1, true) then
            self._display[#self._display + 1] = choice
        end
    end
    self._selected = #self._display > 0 and 1 or 0
    self:_update()
    return self
end

function Chooser:_setQuery(query, input)
    self._query, self._input = query, input
    if type(self._source) == "function" and self._queryChangedCallback then
        -- Let the callback debounce dynamic matching; stale results cannot be selected.
        self._display, self._selected = {}, 0
        self:_update()
    else
        self:refreshChoicesCallback()
    end
    if self._queryChangedCallback then
        self._queryChangedCallback(query)
    end
    return self
end

function Chooser:query(...)
    if select("#", ...) == 0 then
        return self._query
    end
    return self:_setQuery((...) or "", self._input + 1)
end

function Chooser:show(position)
    if self._visible then
        return self
    end
    if self._deleted or not self:_start() then
        return nil
    end
    self._session = self._session + 1
    self._input = 0
    self._visible = true
    self._hiding = nil
    self._position = position
    self:refreshChoicesCallback()
    return self
end

function Chooser:_finish(choice, complete)
    if self._visible then
        self._visible = false
        self._hiding = { choice = choice, complete = complete }
        self:_update()
    end
    return self
end

function Chooser:hide()
    return self:_finish(nil, false)
end

function Chooser:cancel()
    return self:_finish(nil, true)
end

function Chooser:isVisible()
    return self._visible
end

function Chooser:select(row)
    local choice = self._display[row or self._selected]
    if choice and choice.valid == false then
        if self._invalidCallback then
            self._invalidCallback(choice)
        end
        return self
    end
    return self:_finish(choice, true)
end

function Chooser:selectedRow(row)
    if row == nil then
        return self._selected
    end
    self._selected = self._display[row] and row or 0
    self:_update()
    return self
end

function Chooser:selectedRowContents(row)
    return self._display[row or self._selected] or {}
end

for _, name in ipairs({ "queryChangedCallback", "showCallback", "hideCallback", "invalidCallback" }) do
    Chooser[name] = function(self, fn)
        self["_" .. name] = fn
        return self
    end
end

for _, name in ipairs({ "rows", "width", "maxWidth", "placeholderText", "searchSubText" }) do
    local field = name == "placeholderText" and "_placeholder" or "_" .. name
    Chooser[name] = function(self, value)
        if value == nil then
            return self[field]
        end
        if name == "maxWidth" then
            assert(
                type(value) == "number" and value >= 360 and value < math.huge,
                "expected a finite width of at least 360 points"
            )
        elseif name == "rows" or name == "width" then
            assert(
                type(value) == "number" and value >= 1 and value <= 100,
                "expected a number in 1–100"
            )
            value = name == "rows" and math.floor(value) or value
        end
        self[field] = value
        if name == "searchSubText" then
            self:refreshChoicesCallback()
        else
            self:_update()
        end
        return self
    end
end

function Chooser:delete()
    self._deleted = true
    self._visible = false
    self._hiding = nil
    local task = self._task
    self._task = nil
    if task then
        task:closeInput()
        task:terminate()
    end
    instances[self] = nil
end

function M.shutdown()
    for instance in pairs(instances) do
        instance:delete()
    end
end

return M
