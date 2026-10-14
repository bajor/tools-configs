-- Miscellaneous tool plugins

-- Toggleterm
local ok_term, toggleterm = pcall(require, 'toggleterm')
if ok_term then
  local terminal_toggle_key = '<D-f>'
  local float_opts = { border = 'curved' }

  if vim.fn.has('macunix') == 1 then
    local border_columns = 2
    float_opts.width = function()
      return math.max(1, math.floor(vim.o.columns / 2) - border_columns)
    end
    float_opts.col = function()
      return math.ceil(vim.o.columns / 2)
    end
  end

  toggleterm.setup({
    size = 15,
    open_mapping = terminal_toggle_key,
    direction = 'float',
    float_opts = float_opts,
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
