local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup('VpsEditing', { clear = true })

local function disk_state(buf)
  local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
  if not stat then return nil end
  return { mtime = stat.mtime, size = stat.size, ino = stat.ino }
end

local function remember_disk(ev)
  if not vim.bo[ev.buf].modified then
    vim.b[ev.buf].vps_disk_state = disk_state(ev.buf)
  end
end

autocmd({ 'BufReadPost', 'BufWritePost', 'FileChangedShellPost' }, {
  group = group,
  callback = remember_disk,
})

autocmd('FileChangedShell', {
  group = group,
  callback = function(ev)
    vim.v.fcs_choice = ''
    if vim.bo[ev.buf].modified then
      vim.notify('External edit: autosave blocked. Review disk changes before saving.',
        vim.log.levels.WARN)
    elseif vim.v.fcs_reason == 'changed' then
      vim.v.fcs_choice = 'reload'
    end
  end,
})

local function check_disk()
  vim.schedule(function() vim.cmd('checktime') end)
end

autocmd({ 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermLeave' }, {
  group = group,
  callback = check_disk,
})

autocmd({ 'InsertLeave', 'TextChanged' }, {
  group = group,
  callback = function(ev)
    local buf = ev.buf
    if not vim.bo[buf].modified or vim.bo[buf].buftype ~= ''
      or vim.bo[buf].readonly or not vim.bo[buf].modifiable then return end
    local saved = vim.b[buf].vps_disk_state
    if not saved or not vim.deep_equal(saved, disk_state(buf)) then
      check_disk()
      return
    end
    vim.b[buf].vps_autosaving = true
    local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
      vim.cmd('silent update')
    end)
    vim.b[buf].vps_autosaving = nil
    if not ok then vim.notify(tostring(err), vim.log.levels.WARN) end
  end,
})

autocmd('TextYankPost', {
  group = group,
  callback = function()
    vim.hl.on_yank({ higroup = 'IncSearch', timeout = 100 })
  end,
})
