" Leader is spacebar THIS NEEDS TO BE BEFORE LEADER SHORTCUTS
let mapleader = " "


" START OF PLUGINS CONFIG
call plug#begin('~/.vim/plugged')


" Gruvbox color scheme for Windows Terminal
Plug 'morhetz/gruvbox'


" LSPs
Plug 'neovim/nvim-lspconfig'   	        " LSP configurations
Plug 'hrsh7th/nvim-cmp'  	       	" Autocompletion
Plug 'hrsh7th/cmp-nvim-lsp'             " LSP source for nvim-cmp
" Python:
" Install pyright globally via npm:
" sudo apt install nodejs npm -y
" sudo npm install -g pyright
"
" Scala:
Plug 'scalameta/nvim-metals'        " Scala Metals LSP support
" sudo apt-get install unzip
" sudo apt-get install zip
" curl -s "https://get.sdkman.io" | bash
" source "$HOME/.sdkman/bin/sdkman-init.sh"
" sdk install java 17.0.8-tem
" and set as default
" source ~/.bashrc
" curl -fLo coursier https://git.io/coursier-cli && chmod +x coursier && ./coursier
" sudo mv coursier /usr/local/bin/
" coursier bootstrap metals -o metals -f
" export JAVAHOME=/home/m/.sdkman/candidates/java/current/bin/java
" 
" coursier install metals
" export PATH="$PATH:/home/m/.local/share/coursier/bin"

" Ala isort for Python - sort import on save
Plug 'dense-analysis/ale'
let g:ale_fixers = {
\  'python': ['isort'],
\}
let g:ale_fix_on_save = 1
" MAKE SURE YOU HAVE pip isort insall ed


" Telescope
Plug 'nvim-lua/plenary.nvim'          	" Required by Telescope
Plug 'nvim-telescope/telescope.nvim'  	" Fuzzy Finder
" needed: sudo apt install ripgrep
nnoremap <silent> <Leader>ff :Telescope find_files<CR>
" nnoremap <silent> <Leader>fg :Telescope live_grep<CR>
nnoremap <silent> <C-p> :Telescope live_grep<CR>
nnoremap <silent> <Leader>fb :Telescope buffers<CR>


" Rename variable/func with F2
nnoremap <silent> <F2> :lua vim.lsp.buf.rename()<CR>


" Quick terminal
Plug 'akinsho/toggleterm.nvim'


" Comment out sections
Plug 'numToStr/Comment.nvim'


" Mark on left pane/strip modified lines
Plug 'lewis6991/gitsigns.nvim'


" Lua LSP
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim' " Optional: Integrates Mason with lspconfig


call plug#end()
" END OF PLUGINS CONFIG


syntax enable
set background=dark
colorscheme gruvbox


" Map 'jk' to <Esc> in insert mode
inoremap jk <Esc>


" No highlight after / search 
nnoremap <C-n> :nohl<CR>


" Open a vertical split with <leader>v
nnoremap <leader>v :vsplit<CR>
" Navigate splits using Alt+j (left) and Alt+l (right)
" nnoremap <A-h> <C-w>h
nnoremap <leader>h <C-w>h
nnoremap <leader>l <C-w>l


" Redo as r
nnoremap r <C-r>


" Commenting out sections of code 
" In most terminals, Ctrl+/ is actually recognized as Ctrl+_ in Neovim:
nnoremap <C-_> :lua require('Comment.api').toggle.linewise.current()<CR>
xnoremap <C-_> :lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>


" Highlight yanked text briefly
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=100}
augroup END


lua << EOF
-- START OF LUA
-- Quick terminal
require("toggleterm").setup({
    size = 15,                 		-- Height of the terminal window
    open_mapping = [[<A-f>]],  	-- Keybinding to toggle the terminal
    direction = "float",       		-- "horizontal", "vertical", or "float"
    close_on_exit = true,      		-- Close terminal when the process exits
    shell = vim.o.shell,       		-- Use the default shell
})


-- Comment out selected 
require('Comment').setup()


-- PYTHON LSP
local cmp = require("cmp")
cmp.setup({
  sources = {
    { name = "nvim_lsp" },
  },
})

local lspconfig = require("lspconfig")
lspconfig.pyright.setup({})

-- SCALA LSP
-- (Using nvim-metals)
-- In your Lua config (e.g., after the "SCALA LSP" comment)
local metals = require("metals")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local metals_config = metals.bare_config()
metals_config.capabilities = capabilities
metals_config.settings = {
  showImplicitArguments = true,
  excludedPackages = { "akka.actor.typed.javadsl" },
}
metals_config.init_options = {
  statusBarProvider = "on",
}

-- Use Neovim's Lua autocmd function
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt" },
  callback = function()
    metals.initialize_or_attach(metals_config)
  end,
})


-- Suggestoins by LSPs, how to choose and accept them
local cmp = require'cmp'

cmp.setup({
  mapping = {
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Up>'] = cmp.mapping.select_prev_item(),
    ['<Down>'] = cmp.mapping.select_next_item(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  },
})


-- Mark on left pane/strip modified lines
require('gitsigns').setup {
  signs = {
    add          = { text = '+' },
    change       = { text = '~' },
    delete       = { text = '-' },
    topdelete    = { text = 'T' },
    changedelete = { text = 'C' },
  },
  watch_gitdir = {
    interval = 100, -- Check for changes every 100ms
    follow_files = true,
  },
  update_debounce = 100,  -- Debounce time for updates
  current_line_blame = false, -- Optional: show inline blame
}


EOF

