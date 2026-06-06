-- Key mappings
local map = vim.keymap.set
local opts = { silent = true }

local function map_all(mode, lhses, rhs, options)
  for _, lhs in ipairs(lhses) do
    map(mode, lhs, rhs, options)
  end
end

local function safe_require(module_name)
  local ok, module = pcall(require, module_name)
  if not ok then
    vim.notify('Missing module: ' .. module_name, vim.log.levels.WARN)
    return nil
  end
  return module
end

-- Telescope
map('n', '<Leader>ff', ':Telescope find_files<CR>', opts)
map_all('n', { '<D-p>', '<M-p>', '<Leader>fg' }, function()
  require('plugins.telescope').multi_grep()
end, opts)
map('n', '<Leader>fb', ':Telescope buffers<CR>', opts)

-- General
map('n', '<Leader>q', ':cclose<CR>', opts)
map('n', '<F2>', vim.lsp.buf.rename, opts)
map('n', '<Leader>n', ':nohl<CR>', opts)

-- NvimTree
map_all('n', { '<D-S-e>', '<M-S-e>', '<Leader>e' }, ':NvimTreeToggle<CR>', opts)

-- Copilot Chat
map_all('n', { '<D-S-i>', '<M-S-i>', '<Leader>ai' }, function()
  require('CopilotChat').toggle()
end, opts)
map_all('v', { '<D-S-i>', '<M-S-i>', '<Leader>ai' }, function()
  require('CopilotChat').toggle()
end, opts)

-- Jump list navigation
map_all('n', { '<D-h>', '<D-[>', '<M-Left>', '<M-h>', '<M-[>', '[b' }, '<C-o>', opts)
map_all('n', { '<D-]>', '<M-Right>', '<M-l>', '<M-]>', ']b' }, '<C-i>', opts)

-- Editing
map('i', 'jk', '<Esc>')
map('n', 'r', '<C-r>', opts) -- redo (replaces default replace char)

-- Window management
map('n', '<Leader>v', ':vsplit<CR>', opts)
map('n', '<Leader>l', '<C-w>l', opts)
map('n', '<Leader>h', '<C-w>h', opts)
map('n', '<Leader>j', '<Cmd>ToggleTerm<CR>', opts)
map('i', '<Leader>j', '<Esc><Cmd>ToggleTerm<CR>', opts)
map('t', '<Leader>j', '<Cmd>ToggleTerm<CR>', opts)
map('n', '<Leader>k', '<C-w>k', opts)

-- Debugging (DAP)
map('n', '<Leader>dc', function()
  local dap = safe_require('dap')
  if dap then dap.continue() end
end, opts)
map('n', '<Leader>db', function()
  local dap = safe_require('dap')
  if dap then dap.toggle_breakpoint() end
end, opts)
map('n', '<Leader>dB', function()
  local dap = safe_require('dap')
  if not dap then return end
  local condition = vim.fn.input('Breakpoint condition: ')
  dap.set_breakpoint(condition)
end, opts)
map('n', '<Leader>di', function()
  local dap = safe_require('dap')
  if dap then dap.step_into() end
end, opts)
map('n', '<Leader>do', function()
  local dap = safe_require('dap')
  if dap then dap.step_over() end
end, opts)
map('n', '<Leader>dO', function()
  local dap = safe_require('dap')
  if dap then dap.step_out() end
end, opts)
map('n', '<Leader>dr', function()
  local dap = safe_require('dap')
  if dap then dap.repl.toggle() end
end, opts)
map('n', '<Leader>du', function()
  local dapui = safe_require('dapui')
  if dapui then dapui.toggle() end
end, opts)
map('n', '<Leader>dt', function()
  local dap = safe_require('dap')
  if dap then dap.terminate() end
end, opts)

-- Commenting
map_all('n', { '<D-/>', '<M-/>' }, function()
  require('Comment.api').toggle.linewise.current()
end, opts)
map_all('x', { '<D-/>', '<M-/>' }, "<Esc><Cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)
