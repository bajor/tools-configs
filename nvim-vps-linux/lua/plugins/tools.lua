-- Miscellaneous tool plugins

local TOGGLE_TERM_OPEN_MAPPINGS = { [[<D-f>]], [[<M-f>]], [[<C-\>]] }

-- Toggleterm
local ok_term, toggleterm = pcall(require, 'toggleterm')
if ok_term then
  toggleterm.setup({
    size = 15,
    open_mapping = TOGGLE_TERM_OPEN_MAPPINGS,
    direction = 'float',
    float_opts = { border = 'curved' },
  })
  vim.keymap.set('n', '<Leader>t', '<Cmd>ToggleTerm<CR>', { silent = true })
end

-- Comment.nvim
local ok_comment, comment = pcall(require, 'Comment')
if ok_comment then
  comment.setup()
end

-- Gitsigns
local ok_git, gitsigns = pcall(require, 'gitsigns')
if ok_git then
  gitsigns.setup({
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '-' },
      topdelete = { text = 'T' },
      changedelete = { text = 'C' },
    },
    watch_gitdir = { interval = 100, follow_files = true },
    update_debounce = 100,
  })
end
