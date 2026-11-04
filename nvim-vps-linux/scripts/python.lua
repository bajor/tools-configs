-- Integration check: requires uv and the tools installed by VpsInstallTools.
-- These regressions do not require an authenticated external AI service.
vim.lsp.enable('copilot', false)
local project = vim.fn.tempname()
local file = project .. '/test_pair.py'
local function command(argv)
  local result = vim.system(argv, { text = true, env = { UV_LINK_MODE = 'copy' } }):wait()
  assert(result.code == 0, result.stderr)
end
local function output()
  local terminal = require('toggleterm.terminal').get(1)
  if not terminal then return '' end
  return table.concat(vim.api.nvim_buf_get_lines(terminal.bufnr, 0, -1, false), '\n')
end

local function check_python()
  command({ 'uv', 'init', '--bare', project })
  command({ 'uv', 'add', '--project', project, '--dev', 'pytest' })
  vim.fn.writefile({ 'import pytest', '', 'def test_pair():',
    '    assert 0.1 + 0.2 == pytest.approx(0.3)', '',
    'if __name__ == "__main__":', '    print("run-ok")' }, file)
  vim.cmd.edit(file)
  local python = require('config.python')
  assert(python.resolve() == project .. '/.venv/bin/python', 'wrong project interpreter')
  assert(require('dap').configurations.python[1].pythonPath() == python.resolve(), 'DAP drift')
  assert(vim.wait(15000, function()
    return #vim.lsp.get_clients({ bufnr = 0, name = 'pyright' }) == 1
      and #vim.lsp.get_clients({ bufnr = 0, name = 'ruff' }) == 1
  end), 'Python LSP clients did not attach')
  local pyright = assert(vim.lsp.get_clients({ bufnr = 0, name = 'pyright' })[1])
  local ruff = assert(vim.lsp.get_clients({ bufnr = 0, name = 'ruff' })[1])
  assert(not ruff.server_capabilities.hoverProvider, 'duplicate Ruff hover')
  assert(pyright.config.settings.python.pythonPath == python.resolve(), 'LSP interpreter drift')
  local response = pyright:request_sync('textDocument/definition', {
    textDocument = { uri = vim.uri_from_fname(file) }, position = { line = 0, character = 9 },
  }, 10000, 0)
  local location = assert(response and response.result and response.result[1], 'pytest unresolved')
  assert((location.uri or location.targetUri):find('/.venv/', 1, true), 'import outside project venv')
end

local function check_commands()
  local runner = require('config.python_run')
  runner.test_file()
  assert(vim.wait(10000, function() return output():find('1 passed', 1, true) end), output())
  runner.run_file()
  assert(vim.wait(5000, function() return output():find('run-ok', 1, true) end), output())
  runner.rerun()
  assert(vim.wait(5000, function()
    local _, count = output():gsub('run%-ok', '')
    return count >= 2
  end), 'last command did not rerun')
end

local function check_unsaved_rerun()
  vim.cmd.edit(file)
  vim.api.nvim_buf_set_lines(0, 0, 1, false, { '# unsaved change' })
  vim.cmd('enew')
  local toggleterm = require('toggleterm')
  local execute, calls = toggleterm.exec, 0
  toggleterm.exec = function() calls = calls + 1 end
  require('config.python_run').rerun()
  toggleterm.exec = execute
  assert(calls == 0, 'rerun executed stale contents of a modified buffer')
end

vim.schedule(function()
  local active = vim.env.VIRTUAL_ENV
  vim.env.VIRTUAL_ENV = nil
  local ok, err = xpcall(function()
    check_python()
    check_commands()
    check_unsaved_rerun()
  end, debug.traceback)
  vim.env.VIRTUAL_ENV = active
  for _, client in ipairs(vim.lsp.get_clients()) do client:stop() end
  local terminal = require('toggleterm.terminal').get(1)
  if terminal then terminal:shutdown() end
  vim.fn.delete(project, 'rf')
  if not ok then io.stderr:write(err .. '\n'); vim.cmd('cquit 1') end
  print('Python: venv import, one hover, pytest, run and rerun passed')
  vim.cmd('qa!')
end)
