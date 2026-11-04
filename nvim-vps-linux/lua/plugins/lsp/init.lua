-- LSP Configuration
local M = {}

-- Common on_attach for all LSP servers
local function on_attach(client, bufnr)
  local o = { buffer = bufnr, silent = true }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, o)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, o)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, o)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, o)

  vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })


end

-- Get LSP capabilities with nvim-cmp support
function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok then
    capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
  end
  return capabilities
end

function M.setup()
  -- LspAttach autocmd for keymaps
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      on_attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf)
    end,
  })

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
  require('plugins.lsp.servers').setup(M.get_capabilities())

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

  -- Diagnostic colors
  require('plugins.lsp.colors').setup()
end

M.setup()

return M
