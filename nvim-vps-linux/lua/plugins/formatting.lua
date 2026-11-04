-- Priority 3: deterministic formatting only on explicit writes.
require('conform').setup({
  formatters_by_ft = {
    python = { 'ruff_organize_imports', 'ruff_format' },
  },
  default_format_opts = { lsp_format = 'fallback' },
  format_on_save = function(buf)
    if vim.b[buf].vps_autosaving then return nil end
    return {
      timeout_ms = 1500,
      lsp_format = vim.bo[buf].filetype == 'python' and 'never' or 'fallback',
    }
  end,
})
