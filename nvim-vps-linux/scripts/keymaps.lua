-- Real config: nvim --headless '+luafile nvim-vps-linux/scripts/keymaps.lua'
-- Set VPS_KEYMAP_JSON to a file path to also export the global maps and the
-- colorscheme's red, green, yellow and blue ANSI colors.
local MAP_MODES = { 'n', 'i', 't', 'x', 's', 'o', 'c', 'l' }
-- Modes where typed text arrives, so a Space prefix would wait for timeoutlen.
local TYPING_MODES = { i = true, t = true, s = true, c = true, l = true }
-- Modifiers that do not reach the VPS through mosh: Cmd (D), Meta (M), Alt (A).
local UNSUPPORTED_MODIFIERS = { D = true, M = true, A = true }
local KEY_SEPARATOR = '\0'
local BASELINE_ENV = 'VPS_KEYMAP_BASELINE'
local BASELINE_TIMEOUT_MS = 20000
local PICKER_TIMEOUT_MS = 5000
local ANSI_INDEX = { red = 1, green = 2, yellow = 3, blue = 4 }

local function scope_of(buf)
  local filetype = vim.bo[buf].filetype
  return filetype ~= '' and filetype or 'buffer'
end

local function collect_maps()
  local result = {}
  local function add(mode, scope, maps)
    for _, map in ipairs(maps) do
      result[#result + 1] = { mode = mode, scope = scope, map = map }
    end
  end
  for _, mode in ipairs(MAP_MODES) do
    add(mode, 'global', vim.api.nvim_get_keymap(mode))
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        add(mode, scope_of(buf), vim.api.nvim_buf_get_keymap(buf, mode))
      end
    end
  end
  return result
end

local function fingerprint(entry)
  local map = entry.map
  local info = map.callback and debug.getinfo(map.callback, 'S') or {}
  return table.concat({ entry.mode, entry.scope, map.lhs, map.desc or '', map.rhs or '',
    info.source or '', tostring(info.linedefined or 0), tostring(map.expr), tostring(map.nowait) },
    KEY_SEPARATOR)
end

local function display_lhs(lhs)
  return (lhs:gsub('^ ', '<Space>'))
end

local function fail(message)
  io.stderr:write(message .. '\n')
  vim.cmd('cquit 1')
end

local function open_terminal()
  vim.cmd('new')
  return vim.fn.jobstart({ 'cat' }, { term = true })
end

-- A clean Neovim shows which maps are defaults or internal Plug targets.
local function print_baseline()
  local terminal = open_terminal()
  local baseline = {}
  for _, entry in ipairs(collect_maps()) do baseline[fingerprint(entry)] = true end
  vim.fn.jobstop(terminal)
  io.stdout:write(vim.json.encode(baseline) .. '\n')
end

local function load_baseline()
  local script = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p')
  local child = vim.system({ vim.v.progpath, '--clean', '--headless',
    '-c', 'luafile ' .. vim.fn.fnameescape(script) },
    { text = true, env = { [BASELINE_ENV] = '1' } }):wait(BASELINE_TIMEOUT_MS)
  assert(child.code == 0, 'baseline run failed: ' .. (child.stderr or ''))
  return vim.json.decode(child.stdout)
end

-- Cmd, Alt and F-keys, alone or with another modifier: <D-x>, <C-D-x>,
-- <M-C-x>, <F5>, <C-F5>.
local function has_unsupported_key(lhs)
  for token in lhs:upper():gmatch('<([^>]+)>') do
    local parts = vim.split(token, '-', { plain = true })
    for index = 1, #parts - 1 do
      if UNSUPPORTED_MODIFIERS[parts[index]] then return true end
    end
    if parts[#parts]:match('^F%d+$') then return true end
  end
  return false
end

local function violations_for(entry)
  local map, mode = entry.map, entry.mode
  local lhs = map.lhs:upper()
  local leader = map.lhsraw:sub(1, 1) == vim.g.mapleader
  local has_desc = (map.desc or ''):match('%S')
  local reasons = {}
  if TYPING_MODES[mode] and leader then reasons[#reasons + 1] = 'leader in typing mode' end
  if has_unsupported_key(map.lhs) then reasons[#reasons + 1] = 'unsupported key' end
  if (entry.scope == 'global' or leader) and not has_desc then
    reasons[#reasons + 1] = 'needs desc'
  end
  if mode == 'n' and (lhs == '<TAB>' or lhs == '<C-I>' or map.lhsraw == '\t') then
    reasons[#reasons + 1] = 'Tab aliases jump-forward'
  end
  return reasons
end

local function is_public(entry, baseline)
  local lhs = entry.map.lhs
  local native_comment = (lhs == 'gc' and entry.mode ~= 'o') or lhs == 'gcc'
  return not lhs:find('<Plug>', 1, true) and (native_comment or not baseline[fingerprint(entry)])
end

local function to_rows(entries)
  local grouped = {}
  for _, entry in ipairs(entries) do
    local desc = entry.map.desc or ''
    local key = table.concat({ entry.scope, entry.map.lhs, desc }, KEY_SEPARATOR)
    grouped[key] = grouped[key] or {
      lhs = display_lhs(entry.map.lhs), desc = desc, scope = entry.scope, modes = {},
    }
    grouped[key].modes[entry.mode] = true
  end
  local rows = {}
  for _, row in pairs(grouped) do
    row.mode = table.concat(vim.fn.sort(vim.tbl_keys(row.modes)), ',')
    row.modes = nil
    rows[#rows + 1] = row
  end
  table.sort(rows, function(a, b)
    return table.concat({ a.lhs, a.mode, a.scope, a.desc }, KEY_SEPARATOR)
      < table.concat({ b.lhs, b.mode, b.scope, b.desc }, KEY_SEPARATOR)
  end)
  return rows
end

-- The ANSI colors follow the colorscheme, whichever syntax group uses them.
local function ansi_palette()
  local palette = {}
  for name, index in pairs(ANSI_INDEX) do
    palette[name] = assert(vim.g['terminal_color_' .. index], 'terminal_color_' .. index .. ' unset')
  end
  return palette
end

-- Persistent buffer-local maps exist only while their window does. Only the
-- file tree, a terminal and a Telescope prompt are opened here.
local function open_contexts()
  require('nvim-tree.api').tree.open()
  local terminal = open_terminal()
  require('telescope.builtin').find_files()
  local opened = vim.wait(PICKER_TIMEOUT_MS, function() return vim.bo.filetype == 'TelescopePrompt' end)
  assert(opened, 'Telescope prompt did not open')
  return terminal
end

local function check()
  assert(vim.g.mapleader == ' ', 'mapleader must be Space for the leader rules to apply')
  local palette = ansi_palette()
  local baseline = load_baseline()
  local terminal = open_contexts()
  local public, violations = {}, {}
  for _, entry in ipairs(collect_maps()) do
    if is_public(entry, baseline) then
      public[#public + 1] = entry
      local reasons = violations_for(entry)
      if #reasons > 0 then
        violations[#violations + 1] = entry.mode .. ' ' .. display_lhs(entry.map.lhs)
          .. ': ' .. table.concat(reasons, ', ')
      end
    end
  end
  vim.fn.jobstop(terminal)
  if #violations > 0 then fail(table.concat(violations, '\n')) end
  -- Plugin-internal buffer maps are validated above but not exported: their
  -- descriptions and set change with the plugin version.
  local global = vim.tbl_filter(function(entry) return entry.scope == 'global' end, public)
  local rows = to_rows(global)
  local path = vim.env.VPS_KEYMAP_JSON
  if path and path ~= '' then
    vim.fn.writefile({ vim.json.encode({ keymaps = rows, palette = palette }, { sort_keys = true }) }, path)
  end
  io.stdout:write(('Keymaps: %d public maps checked, %d global rows, no violations\n')
    :format(#public, #rows))
end

vim.schedule(function()
  local ok, err = xpcall(vim.env[BASELINE_ENV] == '1' and print_baseline or check, debug.traceback)
  if not ok then fail(err) end
  vim.cmd('qa!')
end)
