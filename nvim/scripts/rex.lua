local rex = require("core.rex")
local function check()
  vim.env.REX_BLOCK = nil
  vim.cmd("only")
  vim.cmd("vsplit")
  vim.cmd("wincmd h")
  local left = vim.api.nvim_get_current_win()
  vim.cmd("wincmd l")
  local right = vim.api.nvim_get_current_win()
  assert(left ~= right)
  vim.api.nvim_set_current_win(left)
  assert(rex.navigate("l") and vim.api.nvim_get_current_win() == right)
  assert(not rex.navigate("l") and vim.api.nvim_get_current_win() == right)
  assert(rex.navigate("h") and vim.api.nvim_get_current_win() == left)
  -- Given insert mode in the left window, When Rex sends Alt+l, Then the
  -- right window is focused in normal mode.
  vim.api.nvim_feedkeys("i" .. vim.keycode("<M-l>"), "xt", false)
  assert(vim.api.nvim_get_current_win() == right, "Alt+l did not reach the right window")
  assert(vim.api.nvim_get_mode().mode == "n", "Alt+l left Neovim in insert mode")
  -- The rex CLI receives one argv element per key=value pair, so spaces
  -- and shell syntax reach the Rex action unchanged.
  local args = rex.action_args("run", { cmd = "pytest -k 'a or b' | tail", cwd = "/tmp/has spaces" })
  assert(vim.deep_equal(args, {
    "rex", "do", "run", "cmd=pytest -k 'a or b' | tail", "cwd=/tmp/has spaces",
  }))
end
vim.schedule(function()
  local ok, err = xpcall(check, debug.traceback)
  if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
  end
  print("Rex navigation and argument checks passed")
  vim.cmd("qa!")
end)
