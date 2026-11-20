local directions = { h = "left", j = "down", k = "up", l = "right" }
local TERMINAL = "com.superlogical.terminal"
-- Panes whose foreground program is this editor get the navigation keys.
local NAVIGATION_EDITOR = "nvim"
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

-- Ctrl+Shift+h/j/k/l moves between panes without a prefix. No Rex key uses
-- Option: on the Polish Pro layout Option types letters such as ł and ń.
-- Returning false passes the key to a Neovim pane unchanged; Neovim maps the
-- same keys, moves between its own windows, and runs `rex focus` at its edge.
-- That mapping also serves clients that skip this keymap, such as the iPad.
for key, direction in pairs(directions) do
  rex.bind("ctrl+shift+" .. key, function()
    if runs_editor() then return false end
    rex.session.focus_direction{ direction = direction }
    return true
  end)
  rex.bind("resize/" .. key, "pane.resize", { direction = direction, amount = RESIZE_STEP })
  -- Always focuses Rex panes, even from a program that does not map
  -- Ctrl+Shift+h/j/k/l, such as a Neovim started without this config.
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

-- ===========================================================================
-- Editor: Rex owns file switching, Neovim only edits.
--
-- One Neovim per project root, started by Rex with --listen and afterwards
-- driven over that socket. Neovim itself needs no configuration for this,
-- which keeps nvim/ identical to a plain checkout: Rex supplies the socket
-- because Rex is what launches the editor.
-- ===========================================================================
local EDITOR_SHARE = 0.6
local EDITOR_PREFIX = "editor:"
-- REX_NVIM_SOCKET_DIR lets the check script keep its sockets out of the
-- directory a real session uses.
local SOCKET_DIR = os.getenv("REX_NVIM_SOCKET_DIR")
  or (os.getenv("HOME") .. "/.local/state/rex-nvim")
-- rex.ui.pick refuses a longer list than this.
local MAX_ITEMS = 2000

-- Arguments are passed as positional parameters so no path or pattern is ever
-- pasted into the script text.
local function sh(script, ...)
  local argv = { "sh", "-c", script, "sh" }
  for _, value in ipairs({ ... }) do argv[#argv + 1] = value end
  return rex.exec.start(argv):wait()
end

local function trim(text)
  return (text:gsub("^%s*(.-)%s*$", "%1"))
end

local function split_lines(text)
  local list = {}
  for line in text:gmatch("[^\n]+") do list[#list + 1] = line end
  return list
end

local function project_root(dir)
  local found = sh('cd "$1" 2>/dev/null && git rev-parse --show-toplevel', dir)
  local root = found.ok and trim(found.stdout) or ""
  return root ~= "" and root or dir
end

local function project_socket(root)
  return SOCKET_DIR .. "/" .. root:gsub("[^%w]", "_") .. ".sock"
end

local function project_label(root)
  return EDITOR_PREFIX .. (root:match("([^/]+)$") or root)
end

-- A socket file can outlive the editor that made it, so ask the server.
local function editor_live(socket)
  return sh('nvim --server "$1" --remote-expr 1 >/dev/null 2>&1', socket).ok
end

local function editor_expr(socket, expression)
  local result = sh('nvim --server "$1" --remote-expr "$2"', socket, expression)
  return result.ok and result.stdout or nil
end

local function block_with_label(label)
  for _, window in ipairs(rex.session.view().windows) do
    for _, layer in ipairs(window.layers) do
      for _, block in ipairs(layer.blocks) do
        if block.label == label then return block.block_id end
      end
    end
  end
end

local function focus_editor(root)
  local block_id = block_with_label(project_label(root))
  if block_id then rex.session.focus_block{ block_id = block_id } end
end

-- Sends the file to the project's Neovim, or starts one in a new pane when no
-- editor is answering on its socket.
local function open_file(ctx, root, path)
  local socket = project_socket(root)
  if editor_live(socket) then
    sh('nvim --server "$1" --remote "$2"', socket, path)
    focus_editor(root)
    return { socket = socket, file = path }
  end
  sh('mkdir -p "$(dirname "$1")" && rm -f "$1"', socket)
  return split_after(ctx, "horizontal", EDITOR_SHARE, rex.layout.block{
    flavor = SHELL, label = project_label(root),
    options = { command = { "nvim", "--listen", socket, path },
                interactive = true, cwd = root },
  })
end

local EXTENSION_ICONS = {
  py = "code", lua = "code", go = "code", rs = "code", ts = "code", js = "code",
  md = "document", txt = "document", rst = "document",
  json = "gear", toml = "gear", yaml = "gear", yml = "gear",
}

local function file_items(paths)
  local items = {}
  for index, path in ipairs(paths) do
    if index > MAX_ITEMS then break end
    items[#items + 1] = {
      id = path,
      title = path:match("([^/]+)$") or path,
      subtitle = path:match("^(.*)/[^/]+$"),
      icon = EXTENSION_ICONS[path:match("%.(%w+)$") or ""] or "document",
    }
  end
  return items
end

rex.action{
  name = "edit", title = "Edit File…", args = { path = "string?", cwd = "string?" },
  run = function(ctx, args)
    local root = project_root(start_dir(args))
    if args.path then return open_file(ctx, root, args.path) end
    -- Tracked plus untracked files, honouring .gitignore; find covers non-Git
    -- directories.
    local listing = sh('cd "$1" && (git ls-files --cached --others '
      .. '--exclude-standard 2>/dev/null || find . -type f -not -path "*/.*")', root)
    local paths = split_lines(listing.stdout)
    if #paths == 0 then
      rex.log("warn", "edit: no files under " .. root)
      return
    end
    local chosen = rex.ui.pick{
      title = "Edit file", placeholder = "Filter files",
      items = file_items(paths), confirm = "Open",
    }
    if chosen == nil then return end
    return open_file(ctx, root, chosen)
  end,
}

local BUFFER_LIST_EXPR =
  [[join(map(getbufinfo({'buflisted':1}), {_, b -> b.bufnr .. ':' .. bufname(b.bufnr)}), "\n")]]

rex.action{
  name = "buffers", title = "Switch Buffer…", args = { cwd = "string?" },
  run = function(_, args)
    local root = project_root(start_dir(args))
    local socket = project_socket(root)
    if not editor_live(socket) then
      rex.log("warn", "buffers: no editor running for " .. root)
      return
    end
    local items = {}
    for _, entry in ipairs(split_lines(editor_expr(socket, BUFFER_LIST_EXPR) or "")) do
      local number, name = entry:match("^(%d+):(.*)$")
      if number then
        items[#items + 1] = {
          id = number,
          title = name ~= "" and (name:match("([^/]+)$") or name) or "[No Name]",
          subtitle = name ~= "" and name or nil,
          icon = "document",
        }
      end
    end
    if #items == 0 then return end
    local chosen = rex.ui.pick{
      title = "Switch buffer", placeholder = "Filter buffers",
      items = items, confirm = "Open",
    }
    if chosen == nil then return end
    editor_expr(socket, 'execute("buffer ' .. chosen .. '")')
    focus_editor(root)
    return { buffer = chosen }
  end,
}

-- The Cmd+Tab of the VS Code setup: cycle buffers with no palette in the way.
rex.action{
  name = "buffer_cycle", title = "Cycle Buffer",
  args = { direction = "string?", cwd = "string?" },
  run = function(_, args)
    local root = project_root(start_dir(args))
    local socket = project_socket(root)
    if not editor_live(socket) then return end
    local command = args.direction == "prev" and "bprevious" or "bnext"
    editor_expr(socket, 'execute("' .. command .. '")')
    focus_editor(root)
    return { direction = command }
  end,
}

rex.action{
  name = "search", title = "Search in Project…",
  args = { pattern = "string?", cwd = "string?" },
  run = function(ctx, args)
    local root = project_root(start_dir(args))
    local pattern = args.pattern or rex.ui.input{
      title = "Search project", placeholder = "ripgrep pattern", confirm = "Search",
    }
    if pattern == nil or trim(pattern) == "" then return end
    local found = sh('cd "$1" && rg --line-number --no-heading --color never -- "$2"',
      root, pattern)
    local items, seen = {}, {}
    for _, line in ipairs(split_lines(found.stdout)) do
      local path, number, text = line:match("^([^:]+):(%d+):(.*)$")
      local id = path and (path .. ":" .. number)
      -- pick rejects duplicate ids, and one line can match more than once.
      if id and not seen[id] and #items < MAX_ITEMS then
        seen[id] = true
        items[#items + 1] = { id = id, title = trim(text), subtitle = id, icon = "code" }
      end
    end
    if #items == 0 then
      rex.log("info", "search: no matches for " .. pattern)
      return
    end
    local chosen = rex.ui.pick{
      title = "Search results", placeholder = "Filter matches",
      items = items, confirm = "Open",
    }
    if chosen == nil then return end
    local path, number = chosen:match("^(.*):(%d+)$")
    local opened = open_file(ctx, root, path)
    local socket = project_socket(root)
    if editor_live(socket) then editor_expr(socket, 'execute("' .. number .. '")') end
    return opened
  end,
}

-- Ctrl+Shift already holds Shift, so previous buffer takes m, next to n.
rex.bind("ctrl+shift+p", "edit")
rex.bind("ctrl+shift+b", "buffers")
rex.bind("ctrl+shift+n", "buffer_cycle", { direction = "next" })
rex.bind("ctrl+shift+m", "buffer_cycle", { direction = "prev" })
rex.bind("ctrl+shift+f", "search")
