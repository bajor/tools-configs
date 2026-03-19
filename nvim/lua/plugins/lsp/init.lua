-- LSP Configuration
local M = {}

-- Diagnostic deduplication (prevents duplicate messages)
local function setup_diagnostic_dedup()
  local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]

  vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    if not result or not result.diagnostics then
      return original_handler(err, result, ctx, config)
    end

    local seen = {}
    local filtered = {}

    for _, diag in ipairs(result.diagnostics) do
      local range = diag.range
      local key = string.format("%s|%d|%d:%d-%d:%d",
        diag.message or "",
        diag.severity or vim.diagnostic.severity.ERROR,
        range.start.line, range.start.character,
        range["end"].line, range["end"].character
      )

      if not seen[key] then
        seen[key] = true
        table.insert(filtered, diag)
      end
    end

    result.diagnostics = filtered
    return original_handler(err, result, ctx, config)
  end
end

-- Common on_attach for all LSP servers
local function on_attach(client, bufnr)
  local o = { buffer = bufnr, silent = true }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, o)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, o)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, o)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, o)

  vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })

  -- Signature help
  local ok_sig, lsp_signature = pcall(require, 'lsp_signature')
  if ok_sig then
    lsp_signature.on_attach({
      bind = true,
      handler_opts = { border = "rounded" }
    }, bufnr)
  end
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
  setup_diagnostic_dedup()

  -- LspAttach autocmd for keymaps
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      on_attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf)
    end,
  })

  -- Mason setup
  require('mason').setup()

  -- Ensure tools are installed
  local ok, registry = pcall(require, 'mason-registry')
  if ok then
    local tools = { 'clangd', 'haskell-language-server', 'gopls', 'elixir-ls', 'pyright', 'ruff', 'ocaml-lsp' }
    for _, tool in ipairs(tools) do
      local pkg = registry.get_package(tool)
      if not pkg:is_installed() then
        pkg:install()
      end
    end
  end

  -- Configure LSP servers
  require('plugins.lsp.servers').setup(M.get_capabilities())

  -- Diagnostic config
  local ok_lines, lsp_lines = pcall(require, 'lsp_lines')
  if ok_lines then lsp_lines.setup() end

  vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = ok_lines,
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
