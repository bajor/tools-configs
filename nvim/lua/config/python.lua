local M = {}
M.root_markers = {
  'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile',
  'ruff.toml', '.ruff.toml', '.git',
}

function M.root()
  return vim.fs.root(0, M.root_markers) or vim.fn.getcwd()
end

-- Priority 3: LSP, debugger and commands share interpreter selection.
function M.resolve(root)
  if vim.env.VIRTUAL_ENV then
    local active = vim.env.VIRTUAL_ENV .. '/bin/python'
    if vim.fn.executable(active) == 1 then return active end
  end
  for _, directory in ipairs({ '.venv', 'venv', 'env' }) do
    local candidate = (root or M.root()) .. '/' .. directory .. '/bin/python'
    if vim.fn.executable(candidate) == 1 then return candidate end
  end
  return vim.fn.exepath('python3')
end

return M
