-- Priority 1: mosh carries OSC 52 writes, but cannot answer reads.
local osc52 = require('vim.ui.clipboard.osc52')
local function paste_from_unnamed()
  return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
end
vim.g.clipboard = {
  name = 'OSC 52 copy, local paste',
  copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
  paste = { ['+'] = paste_from_unnamed, ['*'] = paste_from_unnamed },
}
