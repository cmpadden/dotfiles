-- Pure adapter tests: no UI, processes, Spotlight, or application launches.
local test = {}

function test.run()
    local tasks, errors, completions = {}, {}, {}
    local exists, starts = true, true
    local fake_hs = {
        configdir = "/test",
        json = hs.json,
        fs = {
            attributes = function()
                return exists and {} or nil
            end,
        },
        logger = {
            new = function()
                return { w = function() end }
            end,
        },
        showError = function(message)
            errors[#errors + 1] = message
        end,
        task = {
            new = function(path, callback, stream)
                local task = { path = path, callback = callback, stream = stream, writes = {} }
                function task:start()
                    return starts and self or false
                end
                function task:setInput(data)
                    self.writes[#self.writes + 1] = data
                end
                function task:closeInput()
                    self.closed = true
                end
                function task:terminate()
                    self.terminated = true
                end
                tasks[#tasks + 1] = task
                return task
            end,
        },
    }
    local env = setmetatable({ hs = fake_hs }, { __index = _G })
    local module = assert(loadfile(hs.configdir .. "/modules/chooser.lua", "t", env))()
    local chooser = module.new(function(choice)
        completions[#completions + 1] = { choice = choice }
    end)
    local custom =
        { text = "Firefox", subText = "Browser", image = "favicon", custom = { id = 42 } }
    local invalid = { text = "Find", valid = false }
    local shown, hidden, invalids = 0, 0, 0
    chooser
        :showCallback(function()
            shown = shown + 1
        end)
        :hideCallback(function()
            hidden = hidden + 1
        end)
        :invalidCallback(function()
            invalids = invalids + 1
        end)
        :choices({ custom, invalid })
    assert(chooser:query() == "" and chooser:rows() == 8, "default properties")
    assert(chooser:query(nil) == chooser and chooser:query() == "", "explicit nil clears query")
    assert(chooser:show() == chooser and chooser:isVisible(), "native chooser opens")
    local task = tasks[1]
    assert(task.path == "/test/native/.build/native-chooser", "native binary path")
    local function emit(event, split)
        event.session = event.session or chooser._session
        event.revision = event.revision or chooser._revision
        local line = hs.json.encode(event) .. "\n"
        if split then
            task.stream(task, line:sub(1, 5), "")
            task.stream(task, line:sub(6), "")
        else
            task.stream(task, line, "")
        end
    end
    local function drain()
        while chooser._inflight do
            emit({ event = "ack" })
        end
    end
    local function latest()
        return hs.json.decode(task.writes[#task.writes])
    end
    chooser:query("fi"):rows(6)
    assert(#task.writes == 0, "waits for native readiness")
    emit({ event = "ready" }, true)
    assert(#task.writes == 1 and latest().query == "fi", "split ready event flushes latest state")
    assert(latest().choices[1].image == nil, "ignore unresolved plugin icon placeholders")
    assert(latest().maxWidth == 640, "compact default maximum width")
    chooser:query("fire"):width(45):maxWidth(600)
    assert(#task.writes == 1, "never overwrite unacknowledged task input")
    emit({ event = "ack" })
    assert(
        #task.writes == 2
            and latest().query == "fire"
            and latest().width == 45
            and latest().maxWidth == 600,
        "coalesce snapshots including maximum width"
    )
    drain()
    emit({ event = "shown" })
    assert(shown == 1, "shown callback")
    chooser:showCallback(function()
        error("test callback failure")
    end)
    assert(
        pcall(function()
            emit({ event = "shown" })
        end),
        "callback error must not break transport"
    )
    chooser:showCallback(nil)
    assert(chooser:selectedRowContents() == custom, "retain original choice including metadata")
    emit({ event = "select", revision = chooser._revision - 1, row = 1, query = "fire" })
    assert(chooser:isVisible() and #completions == 0, "reject stale selection revisions")
    emit({ event = "query", input = 3, query = "fi" })
    drain()
    assert(chooser:query() == "fi" and latest().input == 3, "native query changes reach Lua")
    chooser:selectedRow(2)
    drain()
    emit({ event = "select", row = 2, query = "fi" })
    assert(invalids == 1 and chooser:isVisible(), "invalid choice stays open")
    chooser:select(1)
    assert(#completions == 0, "wait for native hide before executing action")
    drain()
    emit({ event = "hidden" })
    assert(
        #completions == 1 and completions[1].choice == custom,
        "dispatch original choice after hide"
    )
    assert(hidden == 1 and not chooser:isVisible(), "hide callback")

    local old_session = chooser._session
    chooser:show()
    drain()
    emit({ event = "cancel", session = old_session })
    assert(chooser:isVisible(), "ignore events from a previous show session")
    chooser:hide()
    drain()
    emit({ event = "hidden" })
    assert(#completions == 1, "programmatic hide does not complete")
    chooser:show()
    drain()
    emit({ event = "cancel" })
    drain()
    emit({ event = "hidden" })
    assert(#completions == 2 and completions[2].choice == nil, "cancel completes with nil")

    chooser:query("browser"):searchSubText(true)
    assert(chooser:selectedRowContents() == custom, "static subtext filtering")
    chooser
        :choices(function()
            return { custom }
        end)
        :query("anything")
    assert(chooser:selectedRowContents() == custom, "callback choices are not filtered twice")
    local query, refreshes = nil, 0
    chooser:choices(function()
        refreshes = refreshes + 1
        return { custom }
    end)
    local before = refreshes
    chooser:rows(5):width(40):maxWidth(580):placeholderText("Search")
    assert(refreshes == before, "display-only changes must not rerun matching")
    chooser
        :queryChangedCallback(function(value)
            query = value
            chooser:refreshChoicesCallback()
        end)
        :query("hello")
    assert(query == "hello", "programmatic query callback")
    assert(refreshes == before + 1, "query callback should match once, not twice")
    assert(chooser:selectedRowContents() == custom, "callback supplies current query results")
    chooser:show()
    drain()
    before = refreshes
    emit({ event = "query", input = 1, query = "native input" })
    drain()
    assert(
        query == "native input" and refreshes == before + 1,
        "native queries use the same matching path"
    )

    local observed
    local static = module.new():choices({ custom, invalid }):queryChangedCallback(function(value)
        observed = value
    end)
    static:query("find")
    assert(
        observed == "find" and static:selectedRowContents() == invalid,
        "static filtering still works with an observer"
    )
    assert(not pcall(function()
        chooser:rows(0)
    end), "reject invalid row count")
    assert(not pcall(function()
        chooser:maxWidth(0)
    end), "reject invalid maximum width")
    chooser:show()
    task.callback(1, "", "crash")
    assert(not chooser:isVisible() and #completions == 3, "helper failure cancels visible chooser")
    chooser:show()
    assert(#tasks == 2, "restart after helper failure")
    module.shutdown()
    assert(
        tasks[2].closed and tasks[2].terminated and not chooser:isVisible(),
        "shutdown closes task"
    )
    assert(chooser:show() == nil, "deleted chooser cannot restart")
    exists = false
    assert(module.new():show() == nil and #errors == 1, "missing helper reports build instructions")
    exists, starts = true, false
    assert(module.new():show() == nil, "start failure does not report visible")
    print(
        "PASS: native chooser transport, filtering, selection, callbacks, sessions, failure, and cleanup"
    )
end

return test
