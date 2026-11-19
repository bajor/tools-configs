local directions = { h = "left", j = "down", k = "up", l = "right" }
local TERMINAL = "com.superlogical.terminal"
-- Panes whose foreground program is this editor get the navigation keys.
local NAVIGATION_EDITOR = "nvim"
local ESC = "\27"
local RESIZE_STEP = 10

local SHELL = "com.superlogical.terminal.shell"
local AGENTS = { claude = true, opencode = true, pi = true }
-- Share of the anchor pane's space that a new agent or run pane takes.
local AGENT_SHARE, RUN_SHARE = 0.4, 0.3
-- Floating shell position as x, y, width, height fractions of the window.
local SCRATCH_BOUNDS = { 0.1, 0.1, 0.8, 0.8 }
local SCRATCH = "scratch"

-- Block calls in a key function or action act on the pane it came from:
-- the focused pane, or REX_BLOCK for `rex do` run inside a Rex terminal.
local function foreground()
  local process = rex.block.call(TERMINAL, "process", {})
  return process and process.foreground
end

local function runs_editor()
  local program = foreground()
  return program ~= nil and program.name == NAVIGATION_EDITOR
end

-- Exclusive stops stray keys reaching the shell while resizing.
rex.mode("resize", { exclusive = true })
rex.bind("ctrl+a>r", "client.mode.enter", { name = "resize" })
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/escape", "client.mode.exit")

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
  -- Always focuses Rex panes, even from a program that ignores Alt keys,
  -- such as a Neovim started without this config.
  rex.bind("ctrl+a>" .. key, "pane.focus." .. direction)
end

-- Without a cwd argument, new panes start where the pane's program runs.
local function start_dir(args)
  if args.cwd then return args.cwd end
  local program = foreground()
  return program and program.cwd or ""
end

local function shell_block(label, options)
  return rex.layout.block{ flavor = SHELL, label = label, options = options }
end

local function split_after(ctx, direction, share, block)
  local split, err = rex.session.new_split{
    anchor_id = ctx.block_id, direction = direction, side = "after",
    ratio = 1 - share, focus = true, layout = block,
  }
  if err ~= nil then error(err, 0) end
  return { block_id = split.block_ids[1] }
end

rex.action{
  name = "agent", title = "Open Agent Pane", args = { name = "string", cwd = "string?" },
  run = function(ctx, args)
    if not AGENTS[args.name] then error("unknown agent: " .. args.name, 0) end
    return split_after(ctx, "horizontal", AGENT_SHARE, shell_block(args.name,
      { command = { args.name }, interactive = true, cwd = start_dir(args) }))
  end,
}

-- The pane stays open after the command exits so its output can be read.
rex.action{
  name = "run", title = "Run Command in Pane", args = { cmd = "string", cwd = "string?" },
  run = function(ctx, args)
    return split_after(ctx, "vertical", RUN_SHARE, shell_block("run", {
      command = { "sh", "-c", args.cmd }, interactive = true, cwd = start_dir(args),
      exit = { on_completion = false },
    }))
  end,
}

local function active_window(view)
  for _, window in ipairs(view.windows) do
    if window.window_id == view.active_window_id then return window end
  end
end

local function holds_scratch(layer)
  for _, block in ipairs(layer.blocks) do
    if block.label == SCRATCH then return true end
  end
  return false
end

local function scratch_layer()
  local window = active_window(rex.session.view())
  for _, layer in ipairs(window and window.layers or {}) do
    if holds_scratch(layer) then return layer end
  end
end

-- One scratch shell per window. Minimizing keeps its program running; the
-- next call brings it back and focuses it. It is recreated after it exits.
rex.action{
  name = "scratch", title = "Toggle Floating Shell", args = { cwd = "string?" },
  run = function(_, args)
    local layer = scratch_layer()
    if layer then
      local state = layer.state == "minimized" and "normal" or "minimized"
      local _, err = rex.session.set_layer_state{
        layer_id = layer.layer_id, state = state, focus = state == "normal" }
      if err ~= nil then error(err, 0) end
      return { layer_id = layer.layer_id, state = state }
    end
    local created, err = rex.session.new_layer{
      bounds = SCRATCH_BOUNDS, focus = true,
      layout = shell_block(SCRATCH, { cwd = start_dir(args) }),
    }
    if err ~= nil then error(err, 0) end
    return { block_id = created.block_ids[1], state = "normal" }
  end,
}

rex.bind("ctrl+a>c", "agent", { name = "claude" })
rex.bind("ctrl+a>o", "agent", { name = "opencode" })
rex.bind("ctrl+a>i", "agent", { name = "pi" })
rex.bind("ctrl+a>e", "scratch")

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
