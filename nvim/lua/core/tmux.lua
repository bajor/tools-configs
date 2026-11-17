local M = {}

local pane_direction = { h = '-L', j = '-D', k = '-U', l = '-R' }

function M.navigate(direction)
  local target = pane_direction[direction]
  assert(target, 'invalid window direction: ' .. tostring(direction))

  local current = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. direction)
  if current ~= vim.api.nvim_get_current_win() then return end

  if not vim.env.TMUX or vim.env.TMUX == '' then return end
  if vim.fn.executable('tmux') ~= 1 then return end

  vim.fn.jobstart({ 'tmux', 'select-pane', target }, { detach = true })
end

return M
