-- Integration check: requires uv and tools installed by NvimInstallTools.
-- A stand-in rex CLI on PATH receives `rex do run cmd=...` and runs cmd in
-- place, so the test never touches a real Rex server.
local original = { REX_BLOCK = vim.env.REX_BLOCK, PATH = vim.env.PATH }
local project = vim.fn.tempname()
local file = project .. '/test_pair.py'
local fake_bin = vim.fn.tempname()
local rex_output, rex_calls = fake_bin .. '/output', fake_bin .. '/calls'
local function command(argv)
  local result = vim.system(argv, { text = true, env = { UV_LINK_MODE = 'copy' } }):wait()
  assert(result.code == 0, result.stderr)
end
local function install_fake_rex()
  vim.fn.mkdir(fake_bin, 'p')
  vim.fn.writefile({ '#!/bin/sh', 'echo "$*" >> ' .. vim.fn.shellescape(rex_calls),
    'for arg; do case $arg in cmd=*) cmd=${arg#cmd=};; esac; done',
    'sh -c "$cmd" >> ' .. vim.fn.shellescape(rex_output) .. ' 2>&1' }, fake_bin .. '/rex')
  vim.fn.setfperm(fake_bin .. '/rex', 'rwx------')
  vim.env.PATH = fake_bin .. ':' .. vim.env.PATH
  vim.env.REX_BLOCK = 'block:test'
end
local function output()
  return table.concat(vim.fn.filereadable(rex_output) == 1 and vim.fn.readfile(rex_output) or {}, '\n')
end
local function call_count()
  return vim.fn.filereadable(rex_calls) == 1 and #vim.fn.readfile(rex_calls) or 0
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
  assert(pyright.config.settings.pyright.disableTaggedHints, 'Pyright tagged hints duplicate Ruff')
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
  for _, call in ipairs(vim.fn.readfile(rex_calls)) do
    assert(call:find('^do run ') and call:find(' cwd=', 1, true), 'unexpected rex call: ' .. call)
  end
end

local function check_unsaved_rerun()
  vim.cmd.edit(file)
  vim.api.nvim_buf_set_lines(0, 0, 1, false, { '# unsaved change' })
  vim.cmd('enew')
  local rex = require('core.rex')
  local run_shell, calls = rex.run_shell, 0
  rex.run_shell = function() calls = calls + 1 end
  require('config.python_run').rerun()
  rex.run_shell = run_shell
  assert(calls == 0, 'rerun executed stale contents of a modified buffer')
end

-- Given no Rex terminal, When a Python file is run, Then Neovim warns and
-- starts nothing.
local function check_outside_rex()
  vim.cmd.edit(file)
  vim.env.REX_BLOCK = nil
  local notify, warnings, calls = vim.notify, {}, call_count()
  vim.notify = function(message) warnings[#warnings + 1] = message end
  require('config.python_run').run_file()
  vim.notify = notify
  assert(call_count() == calls, 'ran a command outside a Rex terminal')
  assert(vim.tbl_contains(warnings, 'Rex CLI requires a native Rex terminal'), vim.inspect(warnings))
end

vim.schedule(function()
  local active = vim.env.VIRTUAL_ENV
  vim.env.VIRTUAL_ENV = nil
  local ok, err = xpcall(function()
    install_fake_rex()
    check_python()
    check_commands()
    check_outside_rex()
    check_unsaved_rerun()
  end, debug.traceback)
  vim.env.VIRTUAL_ENV = active
  for _, client in ipairs(vim.lsp.get_clients()) do client:stop() end
  vim.fn.delete(project, 'rf')
  vim.fn.delete(fake_bin, 'rf')
  if not ok then io.stderr:write(err .. '\n'); vim.cmd('cquit 1') end
  print('Python: venv import, one hover, pytest, run, rerun and outside-Rex warning passed')
  vim.env.REX_BLOCK, vim.env.PATH = original.REX_BLOCK, original.PATH
  vim.cmd('qa!')
end)
