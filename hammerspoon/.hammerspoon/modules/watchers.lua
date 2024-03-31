local helpers = require("modules.helpers")

-- local function callback_pathwatcher(files, flagTables)
--     local mods = {}
--     for ix, file in pairs(files) do
--         local events = {}
--         for event, _ in pairs(flagTables[ix]) do
--             events[#events + 1] = event
--         end
--         mods[#mods + 1] = {
--             name = table.concat(events, ","),
--             value = file,
--         }
--     end
--     helpers:show("Downloads Updated", mods)
-- end

-- DOWNLOAD_WATCHER = hs.pathwatcher.new(os.getenv("HOME") .. "/Downloads/", callback_pathwatcher)
-- DOWNLOAD_WATCHER:start()
