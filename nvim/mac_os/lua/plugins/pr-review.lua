-- PR Review System Configuration
local ok, pr_review = pcall(require, 'pr-review')
if ok then
  pr_review.setup({})
end
