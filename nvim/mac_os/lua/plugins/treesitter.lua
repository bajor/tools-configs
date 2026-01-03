-- Treesitter configuration
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'c', 'lua', 'vimdoc', 'bash',
    'scala', 'java', 'haskell',
    'go', 'gomod', 'gosum',
    'elixir', 'heex', 'eex',
    'python',
    'ocaml', 'ocaml_interface',
  },

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { 'scala' },
  },

  indent = { enable = true },

  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
  },
})
