-- Key mappings
local map = vim.keymap.set
local opts = { silent = true }

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
map('n', '<D-p>', function() require('plugins.telescope').multi_grep() end, opts)
map('n', '<Leader>fb', ':Telescope buffers<CR>', opts)

-- General
map('n', '<Leader>q', ':cclose<CR>', opts)
map('n', '<F2>', vim.lsp.buf.rename, opts)
map('n', '<Leader>n', ':nohl<CR>', opts)

-- NvimTree
map('n', '<D-S-e>', ':NvimTreeToggle<CR>', opts)

-- Copilot Chat
map('n', '<D-S-i>', function() require('CopilotChat').toggle() end, opts)
map('v', '<D-S-i>', function() require('CopilotChat').toggle() end, opts)

-- Jump list navigation
map('n', '<D-h>', '<C-o>', opts)
map('n', '<D-[>', '<C-o>', opts)
map('n', '<D-]>', '<C-i>', opts)
map('n', '<M-Left>', '<C-o>', opts)
map('n', '<M-Right>', '<C-i>', opts)
map('n', '<M-h>', '<C-o>', opts)
map('n', '<M-l>', '<C-i>', opts)
map('n', '[b', '<C-o>', opts)
map('n', ']b', '<C-i>', opts)

-- Editing
map('i', 'jk', '<Esc>')
map('n', 'r', '<C-r>', opts) -- redo (replaces default replace char)

-- Window management
map('n', '<Leader>v', ':vsplit<CR>', opts)
map('n', '<Leader>l', '<C-w>l', opts)
map('n', '<Leader>h', '<C-w>h', opts)
map('n', '<Leader>j', '<C-w>j', opts)
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

-- Commenting (Cmd+/)
map('n', '<D-/>', function() require('Comment.api').toggle.linewise.current() end, opts)
map('x', '<D-/>', "<Esc><Cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)
