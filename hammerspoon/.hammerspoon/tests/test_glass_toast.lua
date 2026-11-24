-- Isolated wrapper tests; no windows, processes, or caffeine changes.
local test = {}

function test.run()
    local exists, starts, creates = true, true, true
    local tasks = {}
    local fallbacks = 0
    local fake_hs = {
        configdir = "/test",
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
        task = {
            new = function(path, callback, args)
                if not creates then
                    return nil
                end
                local task = { path = path, callback = callback, args = args, running = false }
                function task:start()
                    self.running = starts
                    return starts and self or false
                end
                function task:isRunning()
                    return self.running
                end
                function task:terminate()
                    self.running = false
                    self.terminated = true
                    self.callback(15, "", "terminated")
                end
                table.insert(tasks, task)
                return task
            end,
        },
    }
    local env = setmetatable({ hs = fake_hs }, { __index = _G })
    local toast = assert(loadfile(hs.configdir .. "/modules/glass_toast.lua", "t", env))()
    local function fallback()
        fallbacks = fallbacks + 1
    end

    local compact = {
        layout = "compact-bottom",
        title = "Muted",
        symbol = "speaker.slash",
        duration = 1.4,
    }
    local card = {
        layout = "centered-card",
        title = "Saved",
        symbol = "checkmark",
        detail = "Changes are ready.",
        tint = "blue",
    }

    exists = false
    toast:show(card, fallback)
    assert(fallbacks == 1 and #tasks == 0, "missing binary should fall back")
    exists = true
    toast:show(compact, fallback)
    assert(tasks[1].running, "should start native helper")
    assert(
        table.concat(tasks[1].args, "|") == "compact-bottom|Muted|speaker.slash|1.4||label",
        "should pass compact layout, copy, symbol, duration, and default tint"
    )
    assert(
        tasks[1].path == "/test/native/.build/glass-toast",
        "should resolve config-relative binary"
    )
    toast:show(card, fallback)
    assert(tasks[1].terminated and tasks[2].running, "should replace previous toast")
    assert(fallbacks == 1, "termination of replaced toast must not fall back")
    tasks[1].callback(1, "", "stale failure")
    assert(fallbacks == 1, "late callback from replaced toast must be ignored")
    tasks[2].running = false
    tasks[2].callback(1, "", "failure")
    assert(fallbacks == 2, "helper failure should fall back")
    starts = false
    toast:show(compact, fallback)
    assert(fallbacks == 3, "start failure should fall back")
    tasks[#tasks].callback(1, "", "late start failure")
    assert(fallbacks == 3, "start failure must not fall back twice")
    creates = false
    toast:show(compact, fallback)
    assert(fallbacks == 4, "task creation failure should fall back")
    creates, starts = true, true
    toast:show(card, fallback)
    assert(
        table.concat(tasks[#tasks].args, "|")
            == "centered-card|Saved|checkmark|2|Changes are ready.|blue",
        "should pass card layout, copy, symbol, default duration, detail, and tint"
    )
    tasks[#tasks].callback(0, "", "")
    assert(fallbacks == 4, "normal exit must not fall back")
    toast:show(compact, fallback)
    local previous = tasks[#tasks]
    exists = false
    toast:show(card, fallback)
    assert(previous.terminated, "missing binary fallback should cancel the previous toast")
    assert(fallbacks == 5, "missing binary should fall back exactly once after cancellation")
    previous.callback(1, "", "late failure")
    assert(fallbacks == 5, "cancelled helper must not fall back again")
    print(
        "PASS: glass toast arguments, fallback, replacement, stale callback, and normal exit tests"
    )
end

return test
