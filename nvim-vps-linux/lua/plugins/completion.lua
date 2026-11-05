-- Priorities 1/2/3: native menus preserve queued input without completion
-- plugins.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('VpsCompletion', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

local function menu_or_words(key)
  if vim.fn.pumvisible() == 1
    or #vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/completion' }) == 0
    or vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= '' then return key end
  return '<C-x><C-o>'
end
local map = vim.keymap.set
map('i', '<C-n>', function() return menu_or_words('<C-n>') end,
  { expr = true, desc = 'Completion next' })
map('i', '<C-p>', function() return menu_or_words('<C-p>') end,
  { expr = true, desc = 'Completion previous' })
map('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 then
    return vim.fn.complete_info({ 'selected' }).selected < 0 and '<C-n><C-y>' or '<C-y>'
  end
  return '<C-]><CR>'
end, { expr = true, desc = 'Confirm completion or newline' })
map('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true, desc = 'Completion next or Tab' })
