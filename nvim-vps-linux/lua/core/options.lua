-- Core Neovim options
local opt = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = ' '

-- UI
opt.termguicolors = true
opt.cmdheight = 2
opt.display = 'lastline'
opt.signcolumn = 'yes'
opt.background = 'dark'

-- Search
opt.ignorecase = true

-- Behavior
opt.hidden = true
opt.updatetime = 300
opt.shortmess:append('c')
opt.completeopt = { 'menuone', 'noinsert', 'noselect' }

-- Disable netrw for nvim-tree
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
