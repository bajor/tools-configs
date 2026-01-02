-- Key mappings
local map = vim.keymap.set
local opts = { silent = true }

-- Telescope
map('n', '<Leader>ff', ':Telescope find_files<CR>', opts)
map('n', '<D-p>', ':Telescope live_grep<CR>', opts)
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

-- Commenting (Cmd+/)
map('n', '<D-/>', function() require('Comment.api').toggle.linewise.current() end, opts)
map('x', '<D-/>', function() require('Comment.api').toggle.linewise(vim.fn.visualmode()) end, opts)
