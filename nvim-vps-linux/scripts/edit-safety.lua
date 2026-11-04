-- Run with the real config: nvim --headless '+luafile .../edit-safety.lua'
-- These regressions do not require an authenticated external AI service.
vim.lsp.enable('copilot', false)
local path = vim.fn.tempname() .. '.py'
local function event(name)
  vim.api.nvim_exec_autocmds(name, { buffer = 0 })
end

local function check_formatting()
  vim.fn.writefile({ 'import sys', 'import os', '', 'value=  1' }, path)
  vim.cmd.edit(path)
  vim.api.nvim_buf_set_lines(0, 3, 4, false, { 'value=  2' })
  event('TextChanged')
  assert(not vim.bo.modified, 'ordinary edits must autosave')
  assert(vim.fn.readfile(path)[1] == 'import sys', 'autosave organized imports')
  assert(vim.fn.readfile(path)[4] == 'value=  2', 'autosave formatted text')
  vim.cmd('write')
  local lines = vim.fn.readfile(path)
  assert(lines[1] == 'import os', 'explicit write did not organize imports')
  assert(lines[#lines] == 'value = 2', 'explicit write did not format')
end

local function check_external_edits()
  vim.fn.writefile({ 'external = 100' }, path)
  event('CursorHold')
  assert(vim.wait(200, function()
    return vim.api.nvim_get_current_line() == 'external = 100'
  end), 'clean reload failed')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'unsaved = 200' })
  vim.fn.writefile({ 'external = 300' }, path)
  event('TextChanged')
  vim.wait(30)
  assert(vim.fn.readfile(path)[1] == 'external = 300', 'external edit overwritten')
  assert(vim.api.nvim_get_current_line() == 'unsaved = 200', 'local edit lost')
  assert(vim.bo.modified, 'conflict must remain unsaved')
  event('TextChanged')
  vim.wait(30)
  assert(vim.fn.readfile(path)[1] == 'external = 300', 'second autosave overwrote disk')
  vim.fn.delete(path)
  event('InsertLeave')
  assert(not vim.uv.fs_stat(path), 'autosave recreated externally deleted file')
end

vim.schedule(function()
  local ok, err = xpcall(function()
    for _, kind in ipairs({ 'v', 'V', '\0223' }) do
      vim.fn.setreg('"', { 'first', '' }, kind)
      local pasted = vim.g.clipboard.paste['+']()
      assert(vim.deep_equal(pasted[1], vim.fn.getreg('', 1, true)),
        'clipboard paste lost register lines')
      assert(pasted[2] == vim.fn.getregtype(''), 'clipboard paste lost register type')
    end
    check_formatting()
    check_external_edits()
  end, debug.traceback)
  vim.fn.delete(path)
  if not ok then
    io.stderr:write(err .. '\n')
    vim.cmd('cquit 1')
  end
  print('Edit safety: explicit format, plain autosave, reload and conflicts passed')
  vim.cmd('qa!')
end)
