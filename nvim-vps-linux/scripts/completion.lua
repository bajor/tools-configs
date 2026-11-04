-- Exercise batched terminal input with the real config and no popup menu.
vim.schedule(function()
  local ok, err = xpcall(function()
    local function type_text(keys, expected)
      vim.cmd.enew({ bang = true })
      vim.bo.expandtab = false -- the Tab case must not depend on the global default
      require('cmp').setup.buffer({ enabled = false })
      vim.api.nvim_feedkeys(vim.keycode(keys), 'xt', false)
      assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), expected),
        'Completion fallback reordered or lost typed input: ' .. keys)
    end
    type_text('ifoo<CR>bar<Esc>', { 'foo', 'bar' })
    type_text('i<Tab>value<Esc>', { '\tvalue' })
    vim.cmd.iabbrev('teh', 'the')
    type_text('iteh<CR>x<Esc>', { 'the', 'x' })
  end, debug.traceback)
  if not ok then io.stderr:write(err .. '\n'); vim.cmd('cquit 1') end
  print('Completion: batched newline and Tab input kept in order, abbreviations expand on Enter')
  vim.cmd('qa!')
end)
