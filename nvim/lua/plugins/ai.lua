-- Priority 3: scoped agent pane for Claude and opencode. Next edit suggestions
-- need a Copilot subscription, so they stay off.
require('sidekick').setup({
  nes = { enabled = false },
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
