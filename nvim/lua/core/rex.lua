local M = {}
local dir = { h = "left", j = "down", k = "up", l = "right" }
-- Completion only; the agent action in rex/init.lua decides what is allowed.
local AGENTS = { "opencode", "claude", "pi" }
function M.available()
  return vim.env.REX_BLOCK ~= nil and vim.env.REX_BLOCK ~= ""
    and vim.fn.executable("rex") == 1
end
local function invoke(argv)
  if not M.available() then
    vim.notify("Rex CLI requires a native Rex terminal", vim.log.levels.WARN)
    return false
  end
  local errors = {}
  return vim.fn.jobstart(argv, {
    detach = true,
    stderr_buffered = true,
    on_stderr = function(_, data) errors = data end,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.schedule(function()
          local detail = vim.trim(table.concat(errors, " "))
          vim.notify(("Rex CLI failed (exit %d): %s"):format(code, detail), vim.log.levels.WARN)
        end)
      end
    end,
  }) > 0
end
function M.navigate(key)
  local direction = assert(dir[key], "invalid direction")
  local current = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. key)
  if vim.api.nvim_get_current_win() ~= current then return true end
  if not M.available() then return false end
  return invoke({ "rex", "focus", direction })
end
-- Pane layout lives in Rex actions (rex/init.lua); Neovim names the action
-- and passes key=value arguments, sorted so the command line is stable.
function M.action_args(name, args)
  local argv = { "rex", "do", name }
  local keys = vim.tbl_keys(args)
  table.sort(keys)
  for _, key in ipairs(keys) do argv[#argv + 1] = key .. "=" .. args[key] end
  return argv
end
local function action(name, args)
  return invoke(M.action_args(name, args))
end
function M.run_shell(command)
  return action("run", { cmd = command, cwd = vim.fn.getcwd() })
end
function M.scratch()
  return action("scratch", { cwd = vim.fn.getcwd() })
end
function M.agent(name)
  return action("agent", { name = name, cwd = vim.fn.getcwd() })
end
function M.setup()
  vim.api.nvim_create_user_command("RexAgent", function(o) M.agent(o.args) end,
    { nargs = 1, complete = function() return AGENTS end })
  vim.api.nvim_create_user_command("RexRun", function(o) M.run_shell(o.args) end,
    { nargs = "+" })
end
return M
