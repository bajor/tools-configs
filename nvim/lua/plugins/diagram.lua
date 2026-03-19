-- Diagram rendering (mermaid, plantuml, d2, gnuplot)

-- image.nvim (required dependency)
local ok_img, image = pcall(require, 'image')
if ok_img then
  image.setup()
end

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
