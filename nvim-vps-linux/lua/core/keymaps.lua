local map = vim.keymap.set

-- Priority 4: Space + letters for features, Ctrl only in input modes.
map('n', '<leader>ff', '<Cmd>Telescope find_files<CR>', { desc = 'Find files' })
map('n', '<leader>fg', function() require('plugins.telescope').multi_grep() end,
  { desc = 'Find files and content' })
map('n', '<leader>fb', '<Cmd>Telescope buffers<CR>', { desc = 'Find buffers' })
map('n', '<leader>fh', '<Cmd>Telescope help_tags<CR>', { desc = 'Find help' })
map('n', '<leader>fr', '<Cmd>Telescope resume<CR>', { desc = 'Resume picker' })
map('n', '<leader>fs', '<Cmd>Telescope lsp_document_symbols<CR>', { desc = 'Find symbols' })
map('n', '<leader>fd', '<Cmd>Telescope diagnostics<CR>', { desc = 'Find diagnostics' })

map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
map('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
map('n', '<leader>cf', function() require('conform').format({ lsp_format = 'fallback' }) end,
  { desc = 'Format buffer' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
map('n', '<leader>cn', function() vim.diagnostic.jump({ count = 1, float = true }) end,
  { desc = 'Next diagnostic' })
map('n', '<leader>cp', function() vim.diagnostic.jump({ count = -1, float = true }) end,
  { desc = 'Previous diagnostic' })
map('n', 'gd', vim.lsp.buf.definition, { desc = 'Definition' })
map('n', 'gr', vim.lsp.buf.references, { nowait = true, desc = 'References' })
map('n', 'gi', vim.lsp.buf.implementation, { desc = 'Implementation' })
map('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })

map('n', '<leader>rr', function() require('config.python_run').run_file() end,
  { desc = 'Run Python file' })
map('n', '<leader>rt', function() require('config.python_run').test_file() end,
  { desc = 'Test Python file with pytest' })
map('n', '<leader>rl', function() require('config.python_run').rerun() end,
  { desc = 'Rerun last Python command' })

map('n', '<leader>gn', function() require('gitsigns').nav_hunk('next') end,
  { desc = 'Next hunk' })
map('n', '<leader>gp', function() require('gitsigns').nav_hunk('prev') end,
  { desc = 'Previous hunk' })
map('n', '<leader>gv', '<Cmd>Gitsigns preview_hunk<CR>', { desc = 'Preview hunk' })
map('n', '<leader>gs', '<Cmd>Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
map('n', '<leader>gr', '<Cmd>Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
map('n', '<leader>gb', '<Cmd>Gitsigns blame_line<CR>', { desc = 'Blame line' })
map('n', '<leader>gB', '<Cmd>Gitsigns blame<CR>', { desc = 'Blame buffer' })
map('n', '<leader>gd', '<Cmd>Gitsigns diffthis<CR>', { desc = 'Diff file' })

map('n', '<leader>h', '<C-w>h', { desc = 'Window left' })
map('n', '<leader>j', '<C-w>j', { desc = 'Window down' })
map('n', '<leader>k', '<C-w>k', { desc = 'Window up' })
map('n', '<leader>l', '<C-w>l', { desc = 'Window right' })
map('n', '<leader>v', '<Cmd>vsplit<CR>', { desc = 'Vertical split' })
map('n', '<leader>s', '<Cmd>split<CR>', { desc = 'Horizontal split' })
map('n', '<leader>x', '<Cmd>close<CR>', { desc = 'Close window' })
map('n', '<leader>o', '<Cmd>only<CR>', { desc = 'Only window' })
map('n', '<leader>t', '<Cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' })
map('n', '<leader>e', '<Cmd>NvimTreeToggle<CR>', { desc = 'File tree' })
map('n', '<leader>q', '<Cmd>cclose<CR>', { desc = 'Close quickfix' })
map('n', '<leader>n', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
for _, direction in ipairs({ 'h', 'j', 'k', 'l' }) do
  map('t', '<C-' .. direction .. '>', '<C-\\><C-n><C-w>' .. direction,
    { desc = 'Terminal window ' .. direction })
end
map('t', '<C-q>', '<C-\\><C-n>', { desc = 'Terminal normal mode' })

map('n', '<leader>dc', '<Cmd>DapContinue<CR>', { desc = 'Debug continue' })
map('n', '<leader>db', '<Cmd>DapToggleBreakpoint<CR>', { desc = 'Debug breakpoint' })
map('n', '<leader>dB', function()
  require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Debug cond. breakpoint' })
map('n', '<leader>di', '<Cmd>DapStepInto<CR>', { desc = 'Debug step into' })
map('n', '<leader>do', '<Cmd>DapStepOver<CR>', { desc = 'Debug step over' })
map('n', '<leader>dO', '<Cmd>DapStepOut<CR>', { desc = 'Debug step out' })
map('n', '<leader>dr', function() require('dap').repl.toggle() end, { desc = 'Debug REPL' })
map('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Debug UI' })
map('n', '<leader>dt', '<Cmd>DapTerminate<CR>', { desc = 'Debug terminate' })

map({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
map({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end,
  { desc = 'Flash treesitter select' })
map('i', 'jk', '<Esc>', { desc = 'Normal mode' })
map('n', 'r', '<C-r>', { desc = 'Redo' })
