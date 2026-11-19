local directions = { h = "left", j = "down", k = "up", l = "right" }
local TERMINAL = "com.superlogical.terminal"
-- Panes whose foreground program is this editor get the navigation keys.
local NAVIGATION_EDITOR = "nvim"
local ESC = "\27"
local RESIZE_STEP = 10

-- Block calls inside a key function act on the pane the key was sent to.
local function runs_editor()
  local process = rex.block.call(TERMINAL, "process", {})
  local foreground = process and process.foreground
  return foreground ~= nil and foreground.name == NAVIGATION_EDITOR
end

-- Escape leaves the mode; exclusive stops stray keys reaching the shell.
rex.mode("resize", { exclusive = true })
rex.bind("ctrl+a>r", "client.mode.enter", { name = "resize" })
rex.bind("resize/enter", "client.mode.exit")

-- Alt+h/j/k/l moves between panes without a prefix. Neovim receives the key
-- instead, moves between its own windows, and runs `rex focus` at its edge.
-- Writing ESC+key sends the Alt sequence even when macOS Option types text.
for key, direction in pairs(directions) do
  rex.bind("alt+" .. key, function()
    if runs_editor() then
      rex.block.call(TERMINAL, "write", { data = ESC .. key })
    else
      rex.session.focus_direction{ direction = direction }
    end
    return true
  end)
  rex.bind("resize/" .. key, "pane.resize", { direction = direction, amount = RESIZE_STEP })
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
