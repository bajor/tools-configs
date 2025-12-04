  " ========================== BASIC SETTINGS ==========================
  let mapleader = " "
  
  set termguicolors
  set cmdheight=2
  set display=lastline
  set hidden
  set updatetime=300
  set signcolumn=yes 
  set shortmess+=c
  set completeopt=menuone,noinsert,noselect
      
  " ========================== PLUGINS ==========================
  call plug#begin('~/.vim/plugged')
    " UI / theme
    Plug 'morhetz/gruvbox'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'nvim-lualine/lualine.nvim'
  
    " File Explorer                                                                                                                                         
    Plug 'nvim-tree/nvim-tree.lua'                                                                                                                          
                                                                                                                                                            
-   " LSP & completion                                                                                                                                      
    Plug 'hrsh7th/nvim-cmp'                                                                                                                                 
    Plug 'hrsh7th/cmp-nvim-lsp'                                                                                                                             
    Plug 'hrsh7th/cmp-buffer'                                                                                                                               
    Plug 'hrsh7th/cmp-path'                                                                                                                                 
    Plug 'hrsh7th/cmp-vsnip'                                                                                                                                
    Plug 'hrsh7th/vim-vsnip'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'saadparwaiz1/cmp_luasnip'
  
    " Scala
    Plug 'scalameta/nvim-metals'
    Plug 'mfussenegger/nvim-dap'
    Plug 'nvim-neotest/nvim-nio'
    Plug 'rcarriga/nvim-dap-ui'
  
    " Telescope
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
   
    " Terminal, comment, git
    Plug 'akinsho/toggleterm.nvim'
    Plug 'numToStr/Comment.nvim'
 NORMAL   main  +115 ~24 -8  init.vim                                                                                                                              utf-8     vim  Top    1:1  
728 lines yanked into "+

