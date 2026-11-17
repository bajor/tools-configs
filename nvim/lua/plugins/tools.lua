-- Miscellaneous tool plugins


-- Toggleterm
local ok_term, toggleterm = pcall(require, 'toggleterm')
if ok_term then
  toggleterm.setup({
    size = 15,
    direction = 'float',
    float_opts = { border = 'curved' },
  })
end

-- Gitsigns
local ok_git, gitsigns = pcall(require, 'gitsigns')
if ok_git then
  gitsigns.setup({
    preview_config = { border = 'rounded' },
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
