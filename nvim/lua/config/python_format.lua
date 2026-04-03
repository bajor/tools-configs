local M = {}

function M.format()
  -- Organize imports via ruff (no full format — preserves trailing whitespace)
  local clients = vim.lsp.get_clients({ bufnr = 0, name = 'ruff' })
  if #clients > 0 then
    vim.lsp.buf.code_action({
      context = { only = { 'source.organizeImports' } },
      apply = true,
    })
  end
end

return M
