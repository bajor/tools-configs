local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = {},
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, { name = 'luasnip', max_item_count = 5 }, { name = 'path' },
  }, { { name = 'buffer' } }),
  experimental = { ghost_text = false },
})

-- Own these maps so their descriptions are useful in generated documentation.
local function fallback(keys)
  vim.api.nvim_feedkeys(vim.keycode(keys), 'in', false)
end
vim.keymap.set('i', '<C-n>', function()
  if cmp.visible() then cmp.select_next_item() else cmp.complete() end
end, { desc = 'Completion next' })
vim.keymap.set('i', '<C-p>', function()
  if cmp.visible() then cmp.select_prev_item() else cmp.complete() end
end, { desc = 'Completion previous' })
vim.keymap.set('i', '<CR>', function()
  if not cmp.confirm({ select = true }) then fallback('<CR>') end
end, { desc = 'Confirm completion or newline' })
vim.keymap.set({ 'i', 's' }, '<Tab>', function()
  if cmp.visible() then cmp.select_next_item()
  elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
  else fallback('<Tab>') end
end, { desc = 'Completion or snippet next' })
vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if luasnip.jumpable(-1) then luasnip.jump(-1) else fallback('<S-Tab>') end
end, { desc = 'Snippet previous' })
