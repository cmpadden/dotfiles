-- Launcher engine tests without Spotlight, windows, or action execution.
local test = {}

function test.run()
    local query, visible, completion = "", true, nil
    local native = {}
    function native:choices(fn)
        self.choicesFn = fn
        return self
    end
    function native:queryChangedCallback(fn)
        self.changed = fn
        return self
    end
    function native:invalidCallback(fn)
        self.invalid = fn
        return self
    end
    function native:query(value)
        if value ~= nil then
            query = value
            return self
        end
        return query
    end
    function native:isVisible()
        return visible
    end
    function native:refreshChoicesCallback()
        self.refreshed = true
    end
    function native:show()
        visible = true
    end
    function native:hide()
        visible = false
    end
    local env = setmetatable({
        require = function(name)
            assert(name == "modules.chooser")
            return {
                new = function(fn)
                    completion = fn
                    return native
                end,
            }
        end,
        hs = {
            configdir = "/test",
            spoons = {
                scriptPath = function()
                    return "/test/Launcher.spoon/"
                end,
            },
            timer = {
                doAfter = function(_, fn)
                    fn()
                    return { stop = function() end }
                end,
            },
        },
    }, { __index = _G })
    local launcher =
        assert(loadfile(hs.configdir .. "/vendored/Launcher.spoon/init.lua", "t", env))()
    local selected, argument
    local choice = { text = "Test app", plugin = "test", payload = { id = 123 } }
    local plugin = {
        __name = "test",
        commands = function()
            return {
                reveal = {
                    cmd = "reveal",
                    name = "Reveal",
                    description = "Find a file",
                    plugin = "test",
                    fn = function(value)
                        argument = value
                        return { choice }
                    end,
                },
            }
        end,
        bare = function()
            return function()
                return {}
            end
        end,
        completionCallback = function(value)
            selected = value
        end,
    }
    launcher.plugins.test = plugin
    launcher:refreshAllCommands():loadPlugins({ "test" })
    assert(launcher.name == "Launcher" and launcher.chooser == native, "use native adapter")
    query = "reveal file name"
    local result = native.choicesFn()
    assert(argument == "file name" and result[1] == choice, "dispatch command with arguments")
    query = "rev"
    result = native.choicesFn()
    assert(
        #result == 1 and result[1].cmd == "reveal" and result[1].valid == false,
        "command prompt stays open"
    )
    native.invalid(result[1])
    assert(query == "reveal ", "command prompt populates query")
    query = "reveal"
    native.choicesFn()
    assert(argument == ".*", "preserve plugin empty-argument sentinel")
    query = "%"
    assert(#native.choicesFn() == 0, "search queries are literal, not Lua patterns")
    query = "   "
    assert(#native.choicesFn() == 0, "blank query")
    completion(choice)
    assert(selected == choice and selected.payload.id == 123, "dispatch original choice to plugin")
    native.changed()
    assert(native.refreshed, "debounced query refresh")
    plugin.commands = function()
        return {}
    end
    launcher:refreshAllCommands()
    assert(next(launcher.commands) == nil, "remove commands no longer supplied by plugin")
    launcher:toggle()
    assert(not visible, "toggle hides")
    launcher:show("new query")
    assert(visible and query == "new query", "show can prepopulate query")
    print("PASS: Launcher engine, command prompts, plugin dispatch, literal queries, and refresh")
end

return test
