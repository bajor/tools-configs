-- Given a project whose current window has a window-local directory, as a
-- plugin's :lcd would set, When Space+ff and Space+fg pick a file, Then both
-- searched the project root (the global directory) and open that file.
local TIMEOUT_MS = 5000
local POLL_MS = 20

local function wait_for(what, predicate)
  assert(vim.wait(TIMEOUT_MS, predicate, POLL_MS), "timed out waiting for " .. what)
end

local function write(path, text)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile({ text }, path)
end

local function pick(keys, prompt)
  local action_state = require("telescope.actions.state")
  vim.api.nvim_feedkeys(keys, "mx", false)
  wait_for(keys .. " picker", function() return vim.bo.filetype == "TelescopePrompt" end)
  local prompt_bufnr = vim.api.nvim_get_current_buf()
  local picker = action_state.get_current_picker(prompt_bufnr)
  picker:set_prompt(prompt)
  wait_for(keys .. " results", function() return picker.manager and picker.manager:num_results() > 0 end)
  -- Let the sorter settle on the best match before selecting it.
  vim.wait(200)
  require("telescope.actions").select_default(prompt_bufnr)
  wait_for(keys .. " to open a file", function() return vim.bo.filetype ~= "TelescopePrompt" end)
  return vim.api.nvim_buf_get_name(0)
end

local function check()
  local root = vim.fn.tempname()
  local top = vim.fs.joinpath(root, "top-level-file.txt")
  write(top, "rootneedle")
  write(vim.fs.joinpath(root, "sub", "inner.txt"), "other")
  vim.cmd.cd(root)
  vim.cmd.lcd("sub")

  assert(pick(" ff", "top-level-file") == top, "Space+ff did not open the root file")
  assert(vim.fn.getcwd() == vim.fs.joinpath(root, "sub"), "the window lost its local directory")
  assert(pick(" fg", "rootneedle") == top, "Space+fg did not open the root file")
end

vim.schedule(function()
  local ok, err = xpcall(check, debug.traceback)
  if not ok then
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
  end
  print("Search: Space+ff and Space+fg searched the project root")
  vim.cmd("qa!")
end)
