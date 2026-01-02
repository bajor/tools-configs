local M = {}

function M.format()
  -- First organize imports via ruff
  local clients = vim.lsp.get_clients({ bufnr = 0, name = 'ruff' })
  if #clients > 0 then
    -- Ruff's organize imports code action
    vim.lsp.buf.code_action({
      context = { only = { 'source.organizeImports' } },
      apply = true,
    })
    -- Small delay to let organize imports finish
    vim.wait(100)
  end

  -- Then format (ruff will handle this)
  vim.lsp.buf.format({ async = false })
end

return M
