local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
  rex.bind("ctrl+a>" .. key, "pane.focus." .. direction)
  rex.bind("ctrl+a>shift+" .. key, "pane.resize", { direction = direction, amount = 10 })
end
rex.bind("ctrl+a>v", "pane.split.right")
rex.bind("ctrl+a>s", "pane.split.down")
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>x", "pane.close")
rex.bind("ctrl+a>b", "pane.balance")
rex.bind("ctrl+a>f", "pane.float")
rex.bind("ctrl+a>g", "pane.go_to")
rex.bind("ctrl+a>a", "pane.view_activity")
rex.bind("ctrl+a>t", "client.tab.new")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>p", "client.tab.previous")
rex.bind("ctrl+a>q", "session.switch")
rex.bind("ctrl+a>tab", "pane.focus_previous")
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
