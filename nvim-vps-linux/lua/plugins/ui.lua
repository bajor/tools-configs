-- Priority 5: the vivid palette matches the imported Rex theme.
require('solarized-osaka').setup({
  style = 'vivid',
  transparent = true,
  styles = { sidebars = 'transparent', floats = 'transparent' },
  on_highlights = function(highlights)
    for _, severity in ipairs({ 'Error', 'Warn', 'Info', 'Hint' }) do
      highlights['DiagnosticUnderline' .. severity] = { underline = true }
    end
  end,
})
vim.cmd('colorscheme solarized-osaka')

require('nvim-tree').setup({
  disable_netrw = true,
  hijack_netrw = false,
  view = { side = 'right' },
  renderer = { group_empty = true },
  git = { enable = true, ignore = false },
  filters = { dotfiles = false, git_ignored = false },
})

local function mode_color()
  if vim.fn.mode():sub(1, 1) == 'i' then
    return { bg = '#fdf7e7', fg = '#031219', gui = 'bold' }
  end
  return { gui = 'bold' }
end
require('lualine').setup({
  options = {
    theme = 'auto', globalstatus = true,
    component_separators = '', section_separators = '',
  },
  sections = {
    lualine_a = { { 'mode', color = mode_color } },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = {},
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' }, lualine_z = { 'location' },
  },
})
require('incline').setup({})
-- Priority 1: avoid animation churn over mosh; only indent is enabled.
require('snacks').setup({ indent = { enabled = true, animate = { enabled = false } } })
require('nvim-web-devicons').setup({})
pcall(function() require('vim._core.ui2').enable({}) end)

-- Replaced by sidekick in the next PR.
require('CopilotChat').setup({
  window = {
    layout = 'float', width = 0.8, height = 0.6, relative = 'editor',
    row = 2, border = 'rounded',
  },
})
