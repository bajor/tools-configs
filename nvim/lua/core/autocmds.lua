-- Autocommands
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 100 })
  end,
})

-- Format on save
local format_group = augroup('FormatOnSave', { clear = true })

local format_patterns = {
  { pattern = { '*.c', '*.h' } },
  { pattern = { '*.go' } },
  { pattern = { '*.ex', '*.exs' } },
  { pattern = { '*.ml', '*.mli' } },
}

for _, cfg in ipairs(format_patterns) do
  autocmd('BufWritePre', {
    group = format_group,
    pattern = cfg.pattern,
    callback = function()
      vim.lsp.buf.format({ async = false })
    end,
  })
end

-- Python format with import sorting
autocmd('BufWritePre', {
  group = format_group,
  pattern = { '*.py' },
  callback = function()
    require('config.python_format').format()
  end,
})

-- Auto-save after edits
augroup('AutoSave', { clear = true })
autocmd({ 'InsertLeave', 'TextChanged' }, {
  group = 'AutoSave',
  callback = function(ev)
    local buf = ev.buf
    if vim.bo[buf].modified and vim.bo[buf].buftype == '' and vim.fn.filereadable(vim.api.nvim_buf_get_name(buf)) == 1 then
      vim.api.nvim_buf_call(buf, function() vim.cmd('silent! write!') end)
    end
  end,
})
