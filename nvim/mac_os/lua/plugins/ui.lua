-- UI plugins configuration

-- Theme
vim.cmd('syntax enable')
vim.cmd('colorscheme gruvbox')

-- Nvim-tree
local ok_tree, nvim_tree = pcall(require, 'nvim-tree')
if ok_tree then
  nvim_tree.setup({
    view = { side = "right" },
    git = {
      enable = true,
      ignore = false,
    },
    filters = {
      dotfiles = false,
      git_ignored = false,
    },
  })
end

-- Lualine
local ok_lualine, lualine = pcall(require, 'lualine')
if ok_lualine then
  lualine.setup({
    options = {
      theme = 'gruvbox',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { 'filename' },
      lualine_x = { 'g:metals_status', 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
  })
end

-- Devicons
local ok_icons, devicons = pcall(require, 'nvim-web-devicons')
if ok_icons then
  devicons.setup({
    override = {
      scala = { icon = "", color = "#cc3e44", cterm_color = "167", name = "Scala" },
      go = { icon = "", color = "#00ADD8", cterm_color = "74", name = "Go" },
      ex = { icon = "", color = "#a074c4", cterm_color = "140", name = "Elixir" },
      exs = { icon = "", color = "#a074c4", cterm_color = "140", name = "ElixirScript" },
      heex = { icon = "", color = "#a074c4", cterm_color = "140", name = "HEEx" },
    },
  })
end

-- Copilot Chat
local ok_chat, copilot_chat = pcall(require, 'CopilotChat')
if ok_chat then
  local bg = '#282828'
  local fg = '#ebdbb2'
  local border = '#928374'

  vim.api.nvim_set_hl(0, 'CopilotChatNormal', { bg = bg, fg = fg })
  vim.api.nvim_set_hl(0, 'CopilotChatBorder', { bg = bg, fg = border })
  vim.api.nvim_set_hl(0, 'FloatBorder', { bg = bg, fg = border })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = bg, fg = fg })

  copilot_chat.setup({
    window = {
      layout = 'float',
      width = 0.8,
      height = 0.6,
      relative = 'editor',
      row = 2,
      border = 'rounded',
    },
  })
end
