local M = {}
local python = require('config.python')
local last_run

local function execute(command)
  -- Toggleterm has a positional exec API; use terminal 1 for reusable output.
  require('toggleterm').exec(command, 1, 15, nil, 'horizontal')
end

local function run(arguments)
  local file = vim.api.nvim_buf_get_name(0)
  if vim.bo.filetype ~= 'python' or file == '' or vim.bo.modified then
    vim.notify('Save a Python file before running it.', vim.log.levels.WARN)
    return
  end
  local root = python.root()
  local argv = { python.resolve(root) }
  vim.list_extend(argv, arguments)
  argv[#argv + 1] = file
  local command = 'cd -- ' .. vim.fn.shellescape(root) .. ' && '
    .. table.concat(vim.tbl_map(vim.fn.shellescape, argv), ' ')
  last_run = { file = file, command = command }
  execute(command)
end

function M.run_file() run({}) end
function M.test_file() run({ '-m', 'pytest' }) end
function M.rerun()
  if not last_run then
    vim.notify('No previous Python command.', vim.log.levels.INFO)
    return
  end
  local buf = vim.fn.bufnr(last_run.file)
  if buf ~= -1 and vim.bo[buf].modified then
    vim.notify('Save the last-run Python file before rerunning.', vim.log.levels.WARN)
    return
  end
  execute(last_run.command)
end

return M
