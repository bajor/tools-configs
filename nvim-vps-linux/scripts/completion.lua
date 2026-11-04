-- Exercise native completion with real queued input and a visible menu.
local function fail(err)
  io.stderr:write(tostring(err) .. '\n')
  vim.cmd('cquit 1')
end
vim.defer_fn(function() fail('Completion regression timed out') end, 20000)
local function lines() return vim.api.nvim_buf_get_lines(0, 0, -1, false) end
local function type_text(keys, expected)
  vim.cmd.enew({ bang = true })
  vim.bo.expandtab = false
  vim.api.nvim_feedkeys(vim.keycode(keys), 'xt', false)
  assert(vim.deep_equal(lines(), expected), 'Input changed: ' .. keys .. vim.inspect(lines()))
end
local function finish_menu_check()
  local ok, err = xpcall(function()
    assert(vim.deep_equal(lines(), { 'foobarxyz' }), 'Menu confirmation lost trailing input')
    print('Completion: menu confirmation, queued input, word completion and abbreviations passed')
  end, debug.traceback)
  if not ok then fail(err) end
  vim.cmd('qa!')
end
local function open_menu()
  local ok, err = xpcall(function()
    assert(vim.fn.mode() == 'i', 'Expected insert mode')
    vim.fn.complete(1, { 'foobar', 'foobaz' })
    assert(vim.fn.pumvisible() == 1, 'Native completion menu did not open')
    vim.api.nvim_input(vim.keycode('<C-n><C-n><C-p><CR>xyz<Esc>'))
    vim.defer_fn(finish_menu_check, 100)
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
    vim.cmd.enew({ bang = true })
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'foo' })
    vim.cmd.startinsert({ bang = true })
    vim.defer_fn(open_menu, 100)
  end, debug.traceback)
  if not ok then fail(err) end
end)
