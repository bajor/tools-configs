local navigate = require('core.tmux').navigate
local old_tmux = vim.env.TMUX

local function check()
  vim.env.TMUX = nil
  vim.cmd('only')
  vim.cmd('vsplit')
  vim.cmd('wincmd h')
  local left = vim.api.nvim_get_current_win()
  vim.cmd('wincmd l')
  local right = vim.api.nvim_get_current_win()
  assert(left ~= right, 'vertical split is not navigable')
  vim.api.nvim_set_current_win(left)
  navigate('l')
  assert(vim.api.nvim_get_current_win() == right, 'failed to navigate right')
  navigate('l')
  assert(vim.api.nvim_get_current_win() == right, 'edge changed focus without tmux')
  navigate('h')
  assert(vim.api.nvim_get_current_win() == left, 'failed to navigate left')
  vim.cmd('only')
  navigate('h')
  assert(vim.api.nvim_get_current_win() == left, 'single window edge changed focus')
end

vim.schedule(function()
  local ok, err = xpcall(check, debug.traceback)
  vim.env.TMUX = old_tmux
  if not ok then
    io.stderr:write(err .. '\n')
    vim.cmd('cquit 1')
  end
  print('Neovim/tmux: local navigation and safe edges passed')
  vim.cmd('qa!')
end)
