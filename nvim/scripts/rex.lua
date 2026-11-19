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
  local args = rex.split_args("right", { "opencode" },
    { block = "test", cwd = "/tmp/has spaces", ratio = 40, interactive = true })
  assert(vim.deep_equal(args, {
    "rex", "split", "--split=right", "-b", "test", "-c", "/tmp/has spaces",
    "--ratio=40", "--interactive", "--", "opencode",
  }))
  local cmd = rex.split_args("below", { "sh", "-c", "echo ok" },
    { block = "test", cwd = "/tmp", direct = true, keep_open = true })
  assert(vim.tbl_contains(cmd, "--shell=none"))
  assert(vim.tbl_contains(cmd, "--keep-open"))
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
