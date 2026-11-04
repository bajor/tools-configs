-- Plugin installation with vim-plug
local Plug = vim.fn['plug#']

vim.call('plug#begin', vim.fn.stdpath('data') .. '/plugged')

-- UI / Theme
Plug('craftzdog/solarized-osaka.nvim')
Plug('b0o/incline.nvim')
Plug('folke/snacks.nvim')
Plug('folke/flash.nvim')
Plug('nvim-tree/nvim-web-devicons')
Plug('nvim-lualine/lualine.nvim')

-- File Explorer
Plug('nvim-tree/nvim-tree.lua')

-- LSP & Completion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('L3MON4D3/LuaSnip')
Plug('saadparwaiz1/cmp_luasnip')

-- Python debugging
Plug('mfussenegger/nvim-dap')
Plug('nvim-neotest/nvim-nio')
Plug('rcarriga/nvim-dap-ui')

-- Telescope
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })

-- Terminal and Git
Plug('stevearc/conform.nvim')
Plug('akinsho/toggleterm.nvim')
Plug('lewis6991/gitsigns.nvim')

-- Mason (LSP installer)
Plug('williamboman/mason.nvim')


-- Treesitter
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })


-- Agent pane
Plug('folke/sidekick.nvim')



vim.call('plug#end')

-- Load plugin configs after plug#end
require('plugins.lsp')
require('plugins.completion')
require('plugins.treesitter')
require('plugins.telescope')
require('plugins.ui')
require('plugins.tools')
require('plugins.formatting')
require('plugins.ai')
