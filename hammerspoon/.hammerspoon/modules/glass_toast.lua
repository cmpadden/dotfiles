local obj = {}
local task
local log = hs.logger.new("glass_toast", "warning")

-- Build explicitly with `make native`; never compile on the hotkey path.
-- kind: "enabled", "disabled", or "reload".
function obj:show(kind, title, fallback)
    -- Cancel before checking the binary so a fallback also replaces the old toast.
    local previous = task
    task = nil
    if previous and previous:isRunning() then
        previous:terminate()
    end

    local binary = hs.configdir .. "/native/.build/glass-toast"
    if not hs.fs.attributes(binary) then
        fallback()
        return
    end

    local next_task
    next_task = hs.task.new(binary, function(code, _, stderr)
        if task ~= next_task then
            return
        end
        task = nil
        if code ~= 0 then
            log.w("Native toast failed: " .. tostring(stderr))
            fallback()
        end
    end, { kind, title, "2" })
    task = next_task
    if not next_task or not next_task:start() then
        task = nil
        fallback()
    end
end

return obj
