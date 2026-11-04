-- Completion setup with nvim-cmp
local cmp = require('cmp')
local has_luasnip, luasnip = pcall(require, 'luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      if has_luasnip then
        luasnip.lsp_expand(args.body)
      else
        vim.snippet.expand(args.body)
      end
    end,
  },

  -- Keys are mapped below so that each one carries a description.
  mapping = {},

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip', max_item_count = 5 },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  }),

  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
      })[entry.source.name]
      return vim_item
    end
  },

  experimental = {
    ghost_text = false,
  },
})

-- A fallback key is queued before pending typeahead ('i'), so batched input
-- stays in order over mosh, and it is not remapped ('n'), so it cannot call
-- these maps again.
local function fallback(keys)
  vim.api.nvim_feedkeys(vim.keycode(keys), 'in', false)
end

vim.keymap.set('i', '<C-n>', function()
  if cmp.visible() then cmp.select_next_item() else cmp.complete() end
end, { desc = 'Completion next' })
vim.keymap.set('i', '<C-p>', function()
  if cmp.visible() then cmp.select_prev_item() else cmp.complete() end
end, { desc = 'Completion previous' })
vim.keymap.set('i', '<Down>', function()
  if cmp.visible() then cmp.select_next_item() else fallback('<Down>') end
end, { desc = 'Completion next or cursor down' })
vim.keymap.set('i', '<Up>', function()
  if cmp.visible() then cmp.select_prev_item() else fallback('<Up>') end
end, { desc = 'Completion previous or cursor up' })
vim.keymap.set('i', '<CR>', function()
  -- <C-]> expands an abbreviation first, as a plain Enter would.
  if not cmp.confirm({ select = true }) then fallback('<C-]><CR>') end
end, { desc = 'Confirm completion or newline' })
vim.keymap.set({ 'i', 's' }, '<Tab>', function()
  if cmp.visible() then
    cmp.select_next_item()
  elseif has_luasnip and luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  else
    fallback('<Tab>')
  end
end, { desc = 'Completion or snippet next' })
vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if has_luasnip and luasnip.jumpable(-1) then luasnip.jump(-1) else fallback('<S-Tab>') end
end, { desc = 'Snippet previous' })
