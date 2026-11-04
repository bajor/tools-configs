-- Treesitter configuration (new API - nvim-treesitter v1.0+)

-- Install parsers
-- Python is the only project language; the rest support config/help files.
require('nvim-treesitter').install({ 'python', 'lua', 'vim', 'vimdoc', 'bash' })

-- Enable treesitter highlighting for all supported filetypes
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
