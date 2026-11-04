-- Real config: nvim --headless '+luafile nvim-vps-linux/scripts/keymaps.lua'
local modes = { 'n', 'i', 't', 'x', 's', 'o', 'c' }
local function maps()
  local result = {}
  for _, mode in ipairs(modes) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      result[#result + 1] = { mode = mode, scope = 'global', map = map }
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
          result[#result + 1] = { mode = mode,
            scope = vim.bo[buf].filetype ~= '' and vim.bo[buf].filetype or 'buffer', map = map }
        end
      end
    end
  end
  return result
end
local function fingerprint(entry)
  local map = entry.map
  local info = map.callback and debug.getinfo(map.callback, 'S') or {}
  return table.concat({ entry.mode, entry.scope, map.lhs, map.desc or '', map.rhs or '',
    info.source or '', tostring(info.linedefined or 0), tostring(map.expr), tostring(map.nowait) }, '\0')
end
local function emit(value)
  io.stdout:write(vim.json.encode(value) .. '\n')
end

vim.schedule(function()
  if vim.env.VPS_KEYMAP_BASELINE == '1' then
    vim.cmd('new')
    local terminal = vim.fn.jobstart({ 'cat' }, { term = true })
    local baseline = {}
    for _, entry in ipairs(maps()) do baseline[fingerprint(entry)] = true end
    vim.fn.jobstop(terminal)
    emit(baseline)
    vim.cmd('qa!')
    return
  end
  local ok, err = xpcall(function()
    local script = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p')
    local child = vim.system({ vim.v.progpath, '--clean', '--headless',
      '-c', 'luafile ' .. vim.fn.fnameescape(script) },
      { text = true, env = { VPS_KEYMAP_BASELINE = '1' } }):wait()
    assert(child.code == 0, child.stderr)
    local baseline = vim.json.decode(child.stdout)
    -- Exercise persistent buffer-local maps without starting an AI tool.
    require('nvim-tree.api').tree.open()
    vim.cmd('new')
    local terminal = vim.fn.jobstart({ 'cat' }, { term = true })
    local collected, violations = {}, {}
    for _, entry in ipairs(maps()) do
      local map, mode = entry.map, entry.mode
      local native_comment = (map.lhs == 'gc' and mode ~= 'o') or map.lhs == 'gcc'
      if not map.lhs:find('<Plug>', 1, true)
        and (native_comment or not baseline[fingerprint(entry)]) then
        local lhs = map.lhs:upper()
        local leader = map.lhsraw:sub(1, 1) == vim.g.mapleader
        local reason
        if (mode == 'i' or mode == 't') and leader then reason = 'leader in input mode'
        elseif lhs:find('<D-', 1, true) or lhs:find('<M-', 1, true)
          or lhs:find('<A-', 1, true) or lhs:find('<F', 1, true) then reason = 'unsupported key'
        elseif mode == 'n' and leader and not (map.desc or ''):match('%S') then
          reason = 'leader mapping needs desc'
        elseif mode == 'n' and (lhs == '<TAB>' or lhs == '<C-I>' or map.lhsraw == '\t') then
          reason = 'Tab aliases jump-forward'
        end
        if reason then violations[#violations + 1] = mode .. ' ' .. map.lhs .. ': ' .. reason end
        local key = table.concat({ entry.scope, map.lhs, map.desc or '' }, '\0')
        collected[key] = collected[key] or {
          lhs = map.lhs:gsub('^ ', '<Space>'), desc = map.desc or '', scope = entry.scope, modes = {},
        }
        collected[key].modes[mode] = true
      end
    end
    local rows = {}
    for _, item in pairs(collected) do
      item.mode = table.concat(vim.fn.sort(vim.tbl_keys(item.modes)), ',')
      item.modes = nil
      rows[#rows + 1] = item
    end
    table.sort(rows, function(a, b)
      return a.lhs .. a.mode .. a.scope < b.lhs .. b.mode .. b.scope
    end)
    local function color(name)
      local fg = assert(vim.api.nvim_get_hl(0, { name = name, link = false }).fg, name)
      return string.format('#%06x', fg)
    end
    emit({ keymaps = rows, violations = violations, palette = {
      blue = color('Function'), green = color('String'),
      red = color('DiagnosticError'), yellow = color('DiagnosticWarn'),
    } })
    vim.fn.jobstop(terminal)
    if #violations > 0 then
      io.stderr:write(table.concat(violations, '\n') .. '\n')
      vim.cmd('cquit 1')
    end
  end, debug.traceback)
  if not ok then io.stderr:write(err .. '\n'); vim.cmd('cquit 1') end
  vim.cmd('qa!')
end)
