local M = {}
local dir = { h = "left", j = "down", k = "up", l = "right" }
local valid = { right = true, left = true, above = true, below = true }
function M.available()
  return vim.env.REX_BLOCK ~= nil and vim.env.REX_BLOCK ~= ""
    and vim.fn.executable("rex") == 1
end
local function invoke(argv)
  if not M.available() then
    vim.notify("Rex CLI requires a native Rex terminal", vim.log.levels.WARN)
    return false
  end
  return vim.fn.jobstart(argv, {
    detach = true,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.schedule(function() vim.notify("Rex CLI failed: " .. code, vim.log.levels.WARN) end)
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
function M.split_args(direction, command, opts)
  assert(valid[direction], "invalid Rex split direction")
  opts = opts or {}
  local args = { "rex", "split", "--split=" .. direction,
    "-b", opts.block or vim.env.REX_BLOCK, "-c", opts.cwd or vim.fn.getcwd() }
  if opts.ratio then
    assert(opts.ratio >= 1 and opts.ratio <= 99, "invalid ratio")
    args[#args + 1] = "--ratio=" .. tostring(opts.ratio)
  end
  if opts.label then args[#args + 1] = "--label=" .. opts.label end
  if opts.interactive then args[#args + 1] = "--interactive" end
  if opts.direct then args[#args + 1] = "--shell=none" end
  if opts.keep_open then args[#args + 1] = "--keep-open" end
  if command and #command > 0 then
    args[#args + 1] = "--"
    vim.list_extend(args, command)
  end
  return args
end
function M.split(direction, command, opts)
  if not M.available() then
    vim.notify("Rex unavailable", vim.log.levels.WARN)
    return false
  end
  return invoke(M.split_args(direction, command, opts))
end
function M.run_shell(command)
  return M.split("below", { "sh", "-c", command },
    { ratio = 30, label = "run", direct = true, keep_open = true })
end
function M.agent(name)
  assert(({ pi = true, claude = true, opencode = true })[name], "invalid agent")
  return M.split("right", { name }, { ratio = 40, label = name, interactive = true })
end
function M.setup()
  vim.api.nvim_create_user_command("RexSplitRight", function() M.split("right") end, {})
  vim.api.nvim_create_user_command("RexSplitBelow", function() M.split("below") end, {})
  vim.api.nvim_create_user_command("RexAgent", function(o) M.agent(o.args) end,
    { nargs = 1, complete = function() return { "opencode", "claude", "pi" } end })
  vim.api.nvim_create_user_command("RexRun", function(o)
    M.split("below", o.fargs, { ratio = 30, label = "run", interactive = true, keep_open = true })
  end, { nargs = "+" })
  vim.api.nvim_create_user_command("RexZoom", function()
    invoke({ "rex", "zoom" })
  end, {})
  vim.api.nvim_create_user_command("RexFocus", function(o)
    if not vim.tbl_contains({ "left", "right", "up", "down" }, o.args) then
      vim.notify("Expected left, right, up or down", vim.log.levels.WARN)
      return
    end
    invoke({ "rex", "focus", o.args })
  end, { nargs = 1, complete = function() return { "left", "right", "up", "down" } end })
end
return M
