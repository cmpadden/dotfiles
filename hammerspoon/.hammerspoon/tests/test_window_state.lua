-- Window manager state and utility tests
-- Pure-logic tests for modules/wm: circular traversal, state persistence
-- round trips, stale-window cleanup, and ignore-list matching.

local state = require("modules.wm.state")
local util = require("modules.wm.util")

local test = {}

local passed = 0
local failed = 0

local function check(name, condition)
    if condition then
        passed = passed + 1
        print("✅ PASS: " .. name)
    else
        failed = failed + 1
        print("❌ FAIL: " .. name)
    end
end

function test.run()
    print("=== Running Window Manager State Tests ===")
    passed, failed = 0, 0

    -- Circular traversal
    check("advances forward", util.circular_index(3, 1, 1) == 2)
    check("wraps forward", util.circular_index(3, 3, 1) == 1)
    check("wraps backward", util.circular_index(3, 1, -1) == 3)
    check("single element forward", util.circular_index(1, 1, 1) == 1)
    check("single element backward", util.circular_index(1, 1, -1) == 1)
    check("large positive step", util.circular_index(3, 2, 7) == 3)
    check("large negative step", util.circular_index(3, 2, -7) == 1)

    -- Ignore-list matching
    local ignore = util.build_set({ "zoom.us" })
    check("ignored app matches", ignore["zoom.us"] == true)
    check("other app does not match", ignore["Firefox"] == nil)
    check("empty list matches nothing", util.build_set(nil)["zoom.us"] == nil)

    -- State save/load round trip preserving numeric layout keys
    local path = os.tmpname() .. ".json"
    local original = state.new(path)
    original:set_index(1, "Ghostty_7", 2)
    original:set_index(2, "Firefox_123", 3)
    check("save succeeds", (original:save()))

    local restored = state.new(path)
    check("load succeeds", (restored:load()))
    check("numeric layout keys survive round trip", restored:get_index(2, "Firefox_123") == 3)
    check("sequential layout keys survive round trip", restored:get_index(1, "Ghostty_7") == 2)
    check("unknown window defaults to first geometry", restored:get_index(2, "missing") == 1)
    os.remove(path)

    -- Missing state file is guarded
    local missing = state.new("/nonexistent/wm-state.json")
    local ok = missing:load()
    check("missing file load returns false", ok == false)
    check("state usable after failed load", missing:get_index(1, "x") == 1)

    -- Stale-window cleanup
    local store = state.new(path)
    store:set_index(1, "Active_1", 2)
    store:set_index(1, "Stale_2", 3)
    store:set_index(2, "Stale_2", 2)
    store:cleanup({ ["Active_1"] = true })
    check("active window retained", store:get_index(1, "Active_1") == 2)
    check("stale window removed", store:get_index(1, "Stale_2") == 1)
    check("stale window removed from all layouts", store:get_index(2, "Stale_2") == 1)

    -- Window destroyed cleanup
    store:set_index(1, "Closing_3", 2)
    store:remove_window("Closing_3")
    check("destroyed window removed", store:get_index(1, "Closing_3") == 1)

    print(string.format("=== %d passed, %d failed ===", passed, failed))
    return failed == 0
end

return test
