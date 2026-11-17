local cmd = rex.args.cmd
if type(cmd) ~= "string" or cmd == "" then error("Pass cmd=... to run tests", 0) end
local split, err = rex.session.new_split{
  direction = "vertical", side = "after", focus = false,
  layout = rex.layout.block{
    flavor = "com.superlogical.terminal.shell",
    options = {
      command = { "sh", "-c", cmd },
      exit = { on_completion = false },
    },
  },
}
if err ~= nil then error(err, 0) end
local block_id = split.block_ids[1]
local ev = rex.wait("terminal.child_exited", { block_id = block_id }, 600)
if ev == nil then error("Timed out: " .. cmd, 0) end
if ev.exit_code ~= 0 then
  rex.session.zoom_block{ block_id = block_id, zoom = true }
end
return { block_id = block_id, exit_code = ev.exit_code }
