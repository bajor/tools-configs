-- Miscellaneous tool plugins

-- Toggleterm
local ok_term, toggleterm = pcall(require, 'toggleterm')
if ok_term then
  local terminal_toggle_key = '<leader>j'

  toggleterm.setup({
    size = 15,
    open_mapping = terminal_toggle_key,
    direction = 'float',
    float_opts = { border = 'curved' },
  })

  vim.keymap.set({ 'i', 'v', 't' }, terminal_toggle_key, '<Cmd>ToggleTerm direction=float<CR>', { silent = true })
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
