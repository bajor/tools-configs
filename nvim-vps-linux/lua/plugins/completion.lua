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

-- A fallback key is queued before pending typeahead ('i') and is not
-- remapped ('n'), so it cannot call these maps again. This keeps batched
-- input in order on the fallback paths only. With the menu open, cmp still
-- applies a selection or confirmation after pending typeahead.
local function fallback(keys)
  vim.api.nvim_feedkeys(vim.keycode(keys), 'in', false)
end

-- Move the menu selection while it is open, otherwise run `otherwise`.
local function menu_map(lhs, select_item, desc, otherwise)
  vim.keymap.set('i', lhs, function()
    if cmp.visible() then select_item() else otherwise() end
  end, { desc = desc })
end

menu_map('<C-n>', cmp.select_next_item, 'Completion next', cmp.complete)
menu_map('<C-p>', cmp.select_prev_item, 'Completion previous', cmp.complete)
menu_map('<Down>', cmp.select_next_item, 'Completion next or cursor down',
  function() fallback('<Down>') end)
menu_map('<Up>', cmp.select_prev_item, 'Completion previous or cursor up',
  function() fallback('<Up>') end)
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
