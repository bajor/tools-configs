-- Diagnostic highlight colors
local M = {}

local sign_colors = {
  err  = '#cc241d',
  warn = '#d79921',
  info = '#458588',
  hint = '#689d6a',
}

local vt_color = '#7c6f64'
local underline_color = '#5a524c'

function M.setup()
  local set = vim.api.nvim_set_hl

  -- Virtual text and lsp_lines: muted colors
  for _, sev in ipairs({ 'Error', 'Warn', 'Info', 'Hint' }) do
    set(0, 'DiagnosticVirtualText' .. sev, { fg = vt_color })
    set(0, 'LspLines' .. sev, { fg = vt_color })
    set(0, 'LspLinesVirtualText' .. sev, { fg = vt_color })
    set(0, 'DiagnosticFloating' .. sev, { fg = vt_color })
    set(0, 'DiagnosticUnderline' .. sev, { undercurl = true, sp = underline_color })
  end

  -- Signs keep severity colors
  set(0, 'DiagnosticSignError', { fg = sign_colors.err })
  set(0, 'DiagnosticSignWarn', { fg = sign_colors.warn })
  set(0, 'DiagnosticSignInfo', { fg = sign_colors.info })
  set(0, 'DiagnosticSignHint', { fg = sign_colors.hint })

  -- Re-apply on colorscheme change
  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function() M.setup() end
  })
end

return M
