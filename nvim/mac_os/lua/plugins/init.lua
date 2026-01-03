-- Plugin installation with vim-plug
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.vim/plugged')

-- UI / Theme
Plug('morhetz/gruvbox')
Plug('nvim-tree/nvim-web-devicons')
Plug('nvim-lualine/lualine.nvim')

-- File Explorer
Plug('nvim-tree/nvim-tree.lua')

-- LSP & Completion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-vsnip')
Plug('hrsh7th/vim-vsnip')
Plug('L3MON4D3/LuaSnip')
Plug('saadparwaiz1/cmp_luasnip')

-- Scala
Plug('scalameta/nvim-metals')
Plug('mfussenegger/nvim-dap')
Plug('nvim-neotest/nvim-nio')
Plug('rcarriga/nvim-dap-ui')

-- Elixir
Plug('elixir-editors/vim-elixir')

-- Telescope
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })

-- Terminal, Comment, Git
Plug('akinsho/toggleterm.nvim')
Plug('numToStr/Comment.nvim')
Plug('lewis6991/gitsigns.nvim')

-- Mason (LSP installer)
Plug('williamboman/mason.nvim')

-- Inline diagnostics
Plug('Maan2003/lsp_lines.nvim')

-- Treesitter
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

-- Scala tools
Plug('ckipp01/nvim-jvmopts')
Plug('ray-x/lsp_signature.nvim')

-- Copilot
Plug('github/copilot.vim')
Plug('CopilotC-Nvim/CopilotChat.nvim', { branch = 'main' })

vim.call('plug#end')

-- Load plugin configs after plug#end
require('plugins.lsp')
require('plugins.completion')
require('plugins.treesitter')
require('plugins.telescope')
require('plugins.ui')
require('plugins.tools')
require('plugins.pr-review')
