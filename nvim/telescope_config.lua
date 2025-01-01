require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
        ["<C-q>"] = function(prompt_bufnr)
          local actions = require('telescope.actions')
          actions.send_to_qflist(prompt_bufnr)
          actions.open_qflist()
        end,
      },
    },
  },
}


