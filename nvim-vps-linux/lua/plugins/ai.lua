-- Priority 3: one Copilot client for native inline completion and NES.
vim.lsp.config('copilot', {
  filetypes = { 'python' },
  root_markers = require('config.python').root_markers,
})
vim.lsp.enable('copilot')
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('VpsCopilot', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == 'copilot' then
      vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })
    end
  end,
})
require('sidekick').setup({
  cli = {
    win = { layout = 'right' }, watch = true,
    mux = { enabled = false }, picker = 'telescope',
  },
})
-- Sidekick merges defaults; replace these dictionaries to keep two tools,
-- four scoped prompts, and terminal keys owned by core/keymaps.lua.
local config = require('sidekick.config').cli
config.tools = { claude = {}, opencode = {} }
config.win.keys = {}
config.prompts = {
  explain = 'Explain the selected Python code without editing it.\n{selection}',
  diagnostics = 'Fix only these Python diagnostics in {file}. Keep the diff small.\n{diagnostics}',
  test = 'Write one pytest test for this Python function. Change only its test file.\n{function}',
  review = 'Review the Git diff for {file}. Report concrete bugs; do not edit.',
}

local cli = require('sidekick.cli')
local map = vim.keymap.set
map({ 'n', 'x' }, '<leader>aa', function() cli.toggle() end, { desc = 'Toggle agent pane' })
map({ 'n', 'x' }, '<leader>ac', function() cli.toggle({ name = 'claude', focus = true }) end,
  { desc = 'Open Claude' })
map({ 'n', 'x' }, '<leader>ao', function() cli.toggle({ name = 'opencode', focus = true }) end,
  { desc = 'Open opencode' })
map({ 'n', 'x' }, '<leader>as', function() cli.select({ filter = { installed = true } }) end,
  { desc = 'Select agent CLI' })
map({ 'n', 'x' }, '<leader>at', function() cli.send({ msg = '{this}' }) end,
  { desc = 'Send position' })
map({ 'n', 'x' }, '<leader>af', function() cli.send({ msg = '{file}' }) end,
  { desc = 'Send file' })
map({ 'n', 'x' }, '<leader>av', function() cli.send({ msg = '{selection}' }) end,
  { desc = 'Send selection' })
map({ 'n', 'x' }, '<leader>ap', function() cli.prompt() end, { desc = 'Select scoped prompt' })
map({ 'n', 'x' }, '<leader>ad', function() cli.close() end, { desc = 'Detach agent' })
map('i', '<C-y>', function()
  if vim.lsp.inline_completion.get() then return '' end
  if require('sidekick').nes_jump_or_apply() then return '' end
  return '<C-y>'
end, { expr = true, desc = 'Accept AI suggestion' })
map('n', '<C-y>', function() require('sidekick').nes_jump_or_apply() end,
  { desc = 'Accept next edit' })
