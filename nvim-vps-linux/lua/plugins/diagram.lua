-- Diagram rendering (mermaid, plantuml, d2, gnuplot)

local function has_ui()
  return #vim.api.nvim_list_uis() > 0
end

local function tmux_allows_passthrough()
  if not vim.env.TMUX then
    return true
  end

  local result = vim.system({ 'tmux', 'show', '-gv', 'allow-passthrough' }, { text = true }):wait()
  local passthrough = vim.trim(result.stdout)
  return result.code == 0 and (passthrough == 'on' or passthrough == 'all')
end

if not has_ui() or not tmux_allows_passthrough() then
  return
end

-- image.nvim (required dependency)
local ok_img, image = pcall(require, 'image')
if not ok_img then return end

local ok_setup = pcall(image.setup)
if not ok_setup then return end

-- diagram.nvim
local ok, diagram = pcall(require, 'diagram')
if not ok then return end

diagram.setup({
  integrations = {
    require('diagram.integrations.markdown'),
    require('diagram.integrations.neorg'),
  },
  renderer_options = {
    mermaid = {
      theme = 'dark',
      background = 'transparent',
      scale = 2,
    },
  },
})

-- Keymaps (scoped to markdown/neorg via FileType autocmd)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'norg' },
  callback = function(ev)
    local o = { buffer = ev.buf, silent = true }
    vim.keymap.set('n', '<Leader>dd', function() require('diagram').show_diagram_hover() end, o)
    vim.keymap.set('n', '<Leader>dr', function() require('diagram').render() end, o)
    vim.keymap.set('n', '<Leader>dc', function() require('diagram').clear() end, o)
  end,
})
