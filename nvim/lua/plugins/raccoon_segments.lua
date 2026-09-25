-- Raccoon Segments: per-commit AI segment explanations
local ok, segments = pcall(require, 'raccoon_segments')
if ok then
  segments.setup()
end
