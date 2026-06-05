-- Raccoon PR Review System Configuration
local ok, raccoon = pcall(require, 'raccoon')
if ok then
  raccoon.setup({})
end
