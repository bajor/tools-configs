-- LSP Configuration
local M = {}

function M.setup()
  -- Mason setup
  require('mason').setup()

  vim.api.nvim_create_user_command('VpsInstallTools', function()
    local registry = require('mason-registry')
    registry.refresh(function()
      for _, name in ipairs({ 'pyright', 'ruff', 'debugpy' }) do
        local package = registry.get_package(name)
        if not package:is_installed() and not package:is_installing() then
          package:install()
        end
      end
    end)
  end, { desc = 'Install VPS Python tools with Mason' })

  -- Configure LSP servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- Snippet selection can consume subsequent keys in the same terminal batch.
  capabilities.textDocument.completion.completionItem.snippetSupport = false
  require('plugins.lsp.servers').setup(capabilities)

  -- Diagnostic config
  vim.diagnostic.config({
    virtual_text = { spacing = 4 },
    virtual_lines = false,
    severity_sort = true,
    update_in_insert = false,
    signs = true,
    underline = true,
    float = {
      show_header = true,
      source = 'always',
      border = 'rounded',
      focusable = false,
    },
  })

end

M.setup()

return M
