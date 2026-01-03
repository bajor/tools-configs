-- Treesitter configuration (new API - nvim-treesitter v1.0+)

-- Install parsers
require('nvim-treesitter').install({
  'c', 'lua', 'vimdoc', 'bash',
  'scala', 'java', 'haskell',
  'go', 'gomod', 'gosum',
  'elixir', 'heex',
  'python',
  'ocaml', 'ocaml_interface',
})

-- Enable treesitter highlighting for all supported filetypes
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
