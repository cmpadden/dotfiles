local function bind(key, action, args)
    rex.bind("ctrl+a>" .. key, action, args)
end

bind("ctrl+a", "pane.send_key", { key = "ctrl+a" })
bind("r", "client.config.reload")

bind("s", "pane.split", { direction = "right" })
bind("v", "pane.split", { direction = "down" })

local directions = {
    h = "left",
    j = "down",
    k = "up",
    l = "right",
}

for key, direction in pairs(directions) do
    bind(key, "pane.focus", { direction = direction })
    bind("shift+" .. key, "pane.resize", { direction = direction, amount = 5 })
    bind("ctrl+" .. key, "pane.move", { direction = direction })
end

bind("ctrl+w", "pane.move", { direction = "up" })

bind("w", "pane.go_to")
bind("q", "pane.go_to")

bind("shift+s", "session.new")
bind("space", "client.sidebar.toggle")

bind("c", "client.tab.new")
bind("n", "client.tab.next")
bind("p", "client.tab.previous")
bind("z", "pane.zoom")
bind("x", "pane.close")
bind(",", "client.tab.rename")
