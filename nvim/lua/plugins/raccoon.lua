-- Raccoon PR Review System Configuration
local ok, raccoon = pcall(require, 'raccoon')
if ok then
  raccoon.setup({})
end

local ok_inline_diff, inline_diff = pcall(require, 'raccoon_inline_diff')
if ok_inline_diff then
  inline_diff.setup()
end
