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
" sdk install java 11.0.20-tem
" sdk default java 11.0.20-tem
		" sdk install java 8.0.275.hs-adpt
		" sdk install java 8.0.275.hs-adpt
		" sdk default java 8.0.275.hs-adpt
" source ~/.bashrc
" curl -fLo coursier https://git.io/coursier-cli && chmod +x coursier && ./coursier
" sudo mv coursier /usr/local/bin/
" coursier bootstrap metals -o metals -f
" export JAVAHOME=/home/m/.sdkman/candidates/java/current/bin/java
" 
" coursier install metals
" export PATH="$PATH:/home/m/.local/share/coursier/bin"


" Telescope
Plug 'nvim-lua/plenary.nvim'          	" Required by Telescope
Plug 'nvim-telescope/telescope.nvim'  	" Fuzzy Finder
" needed: sudo apt install ripgrep
nnoremap <silent> <Leader>ff :Telescope find_files<CR>
nnoremap <silent> <Leader>fg :Telescope live_grep<CR>
nnoremap <silent> <Leader>fb :Telescope buffers<CR>
nnoremap <silent> <Leader>fh :Telescope help_tags<CR>


call plug#end()
" END OF PLUGINS CONFIG

syntax enable
set background=dark " or light
colorscheme gruvbox

" Map 'jk' to <Esc> in insert mode
inoremap jk <Esc>

" Leader is spacebar
let mapleader = " "

" No highlight after / search 
nnoremap <C-n> :nohl<CR>

" Highlight yanked text briefly
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=100}
augroup END


lua << EOF
local cmp = require'cmp'
cmp.setup {
  sources = {
    { name = 'nvim_lsp' },
  },
}
local lspconfig = require'lspconfig'	
lspconfig.pyright.setup{}


