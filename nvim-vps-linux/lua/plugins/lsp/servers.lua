-- LSP Server configurations
local M = {}

local PROJECT_VENV_DIRS = { '.venv', 'venv', 'env', '.env' }
local DEFAULT_PYTHON = 'python3'
local DAP_UI_SIDEBAR_WIDTH = 26
local DAP_UI_BOTTOM_HEIGHT = 12

local function get_debugpy_adapter_command()
  local mason_debugpy_python = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python'
  if vim.fn.executable(mason_debugpy_python) == 1 then
    return mason_debugpy_python
  end
  return DEFAULT_PYTHON
end

local function resolve_python_path()
  local active_venv = vim.env.VIRTUAL_ENV
  if active_venv then
    local venv_python = active_venv .. '/bin/python'
    if vim.fn.executable(venv_python) == 1 then
      return venv_python
    end
  end

  local cwd = vim.fn.getcwd()
  for _, venv_dir in ipairs(PROJECT_VENV_DIRS) do
    local candidate = cwd .. '/' .. venv_dir .. '/bin/python'
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  return DEFAULT_PYTHON
end

local function setup_dap_ui()
  local ok_dap, dap = pcall(require, 'dap')
  if not ok_dap then return end

  local ok_ui, dapui = pcall(require, 'dapui')
  if not ok_ui then return end

  dapui.setup({
    layouts = {
      {
        -- Algorithm-first layout: variable scopes + breakpoints, no watches/thread-heavy stacks.
        elements = {
          { id = 'scopes', size = 0.75 },
          { id = 'breakpoints', size = 0.25 },
        },
        size = DAP_UI_SIDEBAR_WIDTH,
        position = 'left',
      },
      {
        elements = {
          { id = 'repl', size = 1.0 },
        },
        size = DAP_UI_BOTTOM_HEIGHT,
        position = 'bottom',
      },
    },
  })

  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
end

function M.setup(capabilities)
  -- Pyright (Python)
  vim.lsp.config.pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
    capabilities = capabilities,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = 'workspace',
          typeCheckingMode = 'basic',
        },
      },
    },
  }
  vim.lsp.enable('pyright')

  -- Ruff (Python linter/formatter)
  vim.lsp.config.ruff = {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', 'setup.py', '.git' },
    capabilities = capabilities,
    settings = {
      organizeImports = true,
      fixAll = true,
    },
  }
  vim.lsp.enable('ruff')

  -- Python DAP (debugpy)
  M.setup_python_dap()
  setup_dap_ui()

end

function M.setup_python_dap()
  local ok_dap, dap = pcall(require, 'dap')
  if not ok_dap then return end

  dap.adapters.python = {
    type = 'executable',
    command = get_debugpy_adapter_command(),
    args = { '-m', 'debugpy.adapter' },
  }

  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      name = 'Python: Current File',
      program = '${file}',
      cwd = '${workspaceFolder}',
      console = 'integratedTerminal',
      justMyCode = false,
      pythonPath = resolve_python_path,
    },
    {
      type = 'python',
      request = 'launch',
      name = 'Python: Current File (Args)',
      program = '${file}',
      cwd = '${workspaceFolder}',
      console = 'integratedTerminal',
      justMyCode = false,
      args = function()
        local raw_args = vim.fn.input('Program args: ')
        return vim.split(raw_args, '%s+', { trimempty = true })
      end,
      pythonPath = resolve_python_path,
    },
    {
      type = 'python',
      request = 'attach',
      name = 'Python: Attach (localhost:5678)',
      connect = { host = '127.0.0.1', port = 5678 },
      cwd = '${workspaceFolder}',
      justMyCode = false,
      pythonPath = resolve_python_path,
    },
  }
end

return M
