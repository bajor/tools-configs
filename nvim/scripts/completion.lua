-- Exercise native completion with real queued input and a visible menu.
local TIMEOUT_MS = 20000
local INPUT_SETTLE_MS = 100
local completed_requests = 0
vim.api.nvim_create_autocmd('LspRequest', {
  callback = function(ev)
    if ev.data.request.method == 'textDocument/completion'
      and ev.data.request.type == 'complete' then
      completed_requests = completed_requests + 1
    end
  end,
})
local project = vim.fn.tempname()
local function cleanup()
  for _, client in ipairs(vim.lsp.get_clients()) do client:stop() end
  vim.fn.delete(project, 'rf')
end
local function fail(err)
  cleanup()
  io.stderr:write(tostring(err) .. '\n')
  vim.cmd('cquit 1')
end
vim.defer_fn(function() fail('Completion regression timed out') end, TIMEOUT_MS)
local function lines() return vim.api.nvim_buf_get_lines(0, 0, -1, false) end
local function type_text(keys, expected)
  vim.cmd.enew({ bang = true })
  vim.bo.expandtab = false
  vim.api.nvim_feedkeys(vim.keycode(keys), 'xt', false)
  assert(vim.deep_equal(lines(), expected), 'Input changed: ' .. keys .. vim.inspect(lines()))
end
local function finish_lsp_check()
  local ok, err = xpcall(function()
    assert(vim.deep_equal(lines(), { 'value = "x"', 'value.lowerxyz' }),
      'Pyright menu confirmation lost trailing input: ' .. vim.inspect(lines()))
    -- Request completion and continue typing without waiting for its response.
    local before = completed_requests
    vim.api.nvim_feedkeys(vim.keycode('ccvalue.low<C-n>xyz<CR>tail<Esc>'), 'xt', false)
    assert(vim.wait(TIMEOUT_MS, function() return completed_requests > before end),
      'Batched input did not receive a completion response')
    vim.schedule(function()
      local passed, failure = xpcall(function()
        assert(vim.deep_equal(lines(), { 'value = "x"', 'value.lowxyz', 'tail' }),
          'Late LSP response changed batched input: ' .. vim.inspect(lines()))
      end, debug.traceback)
      if not passed then fail(failure) end
      cleanup()
      print('Completion: native/Pyright menus, batched input, words, macros and abbreviations passed')
      vim.cmd('qa!')
    end)
  end, debug.traceback)
  if not ok then fail(err) end
end

local function accept_lsp_menu()
  local ok, err = xpcall(function()
    local info = vim.fn.complete_info({ 'items', 'selected' })
    if vim.fn.pumvisible() == 0 or #info.items == 0 then
      vim.defer_fn(accept_lsp_menu, INPUT_SETTLE_MS)
      return
    end
    local lower
    for index, item in ipairs(info.items) do
      if item.word == 'lower' then lower = index; break end
    end
    assert(lower, 'Pyright did not complete str.lower: ' .. vim.inspect(info.items))
    assert(info.selected == -1, 'Expected no initial selection')
    vim.api.nvim_input(vim.keycode(string.rep('<C-n>', lower) .. '<CR>xyz<Esc>'))
    vim.defer_fn(finish_lsp_check, INPUT_SETTLE_MS)
  end, debug.traceback)
  if not ok then fail(err) end
end

local function check_lsp()
  vim.fn.mkdir(project, 'p')
  vim.fn.writefile({ '[project]', 'name = "completion-check"', 'version = "0.0.0"' },
    project .. '/pyproject.toml')
  local file = project .. '/completion.py'
  vim.fn.writefile({ 'value = "x"', 'value.low' }, file)
  vim.cmd.edit(file)
  assert(vim.wait(TIMEOUT_MS, function()
    return #vim.lsp.get_clients({ bufnr = 0, name = 'pyright' }) == 1
  end), 'Pyright did not attach')
  local client = vim.lsp.get_clients({ bufnr = 0, name = 'pyright' })[1]
  assert(not client.capabilities.textDocument.completion.completionItem.snippetSupport,
    'LSP snippets must stay disabled for queued input')
  assert(vim.bo.omnifunc == 'v:lua.vim.lsp.omnifunc', 'Completion attach hook did not run')
  vim.api.nvim_win_set_cursor(0, { 2, #'value.low' })
  vim.cmd.startinsert({ bang = true })
  vim.defer_fn(function()
    vim.api.nvim_input(vim.keycode('<C-n>'))
    vim.defer_fn(accept_lsp_menu, INPUT_SETTLE_MS)
  end, INPUT_SETTLE_MS)
end

local function finish_menu_check()
  local ok, err = xpcall(function()
    assert(vim.deep_equal(lines(), { 'foobarxyz' }), 'Menu confirmation lost trailing input')
    check_lsp()
  end, debug.traceback)
  if not ok then fail(err) end
end
local function open_menu()
  local ok, err = xpcall(function()
    assert(vim.fn.mode() == 'i', 'Expected insert mode')
    vim.fn.complete(1, { 'foobar', 'foobaz' })
    assert(vim.fn.pumvisible() == 1, 'Native completion menu did not open')
    vim.api.nvim_input(vim.keycode('<C-n><C-n><C-p><CR>xyz<Esc>'))
    vim.defer_fn(finish_menu_check, INPUT_SETTLE_MS)
  end, debug.traceback)
  if not ok then fail(err) end
end
vim.schedule(function()
  local ok, err = xpcall(function()
    type_text('ifoo<CR>bar<Esc>', { 'foo', 'bar' })
    type_text('i<Tab>value<Esc>', { '\tvalue' })
    vim.cmd.iabbrev('teh', 'the')
    type_text('iteh<CR>x<Esc>', { 'the', 'x' })
    type_text('ifoobar<CR>foo<C-n><CR><Esc>', { 'foobar', 'foobar' })
    type_text('qaifoobar<CR>foo<C-n><CR><Esc>q', { 'foobar', 'foobar' })
    type_text('@a', { 'foobar', 'foobar' })
    vim.cmd('setfiletype lua')
    assert(vim.bo.omnifunc ~= '', 'Expected non-LSP ftplugin omnifunc')
    vim.api.nvim_feedkeys(vim.keycode('Gofoo<C-n><CR><Esc>'), 'xt', false)
    assert(lines()[3] == 'foobar', 'Non-LSP ftplugin lost native word completion')
    vim.cmd.enew({ bang = true })
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'foo' })
    vim.cmd.startinsert({ bang = true })
    vim.defer_fn(open_menu, INPUT_SETTLE_MS)
  end, debug.traceback)
  if not ok then fail(err) end
end)
