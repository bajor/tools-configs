" NOTES:
" install newest neovim, not default
" install new plugin :PlugInstall


call plug#begin('~/.vim/plugged')


" Gruvbox color scheme for Windows Terminal
Plug 'morhetz/gruvbox'


" LSPs
Plug 'neovim/nvim-lspconfig'         " LSP configurations
Plug 'hrsh7th/nvim-cmp'             " Autocompletion
Plug 'hrsh7th/cmp-nvim-lsp'         " LSP source for nvim-cmp
Plug 'scalameta/nvim-metals'        " Scala Metals LSP support
" Python:
" Install pyright globally via npm:
" sudo apt install nodejs npm -y
" sudo npm install -g pyright
"
" Scala:
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
" export PATH=$JAVA_HOME/bin:$PAT
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
" <Leader>ff: Search for files in your current working directory.
" <Leader>fg: Perform a live grep search across your project.
" <Leader>fb: Show a list of open buffers.
" <Leader>fh: Search through Neovim help tags.
" :Telescope git_files: Search files in a Git repository (requires Git).


Plug 'Pocco81/auto-save.nvim'


call plug#end()

lua require('telescope_config')

syntax enable
set background=dark " or light
colorscheme gruvbox

" Map 'jk' to <Esc> in insert mode
inoremap jk <Esc>

" Leader is spacebar
let mapleader = " "

" Highlight yanked text briefly
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=100}
augroup END



" Gruvbox color scheme for Windows Terminal

" Name of the color scheme
" "name": "Gruvbox Dark"

" Background and foreground colors
" "background": "#282828", " Background color (dark)
" "foreground": "#ebdbb2", " Foreground color (light text)

" Normal colors
" "black": "#282828",      " Black
" "red": "#cc241d",        " Red
" "green": "#98971a",      " Green
" "yellow": "#d79921",     " Yellow
" "blue": "#458588",       " Blue
" "purple": "#b16286",     " Magenta (Purple)
" "cyan": "#689d6a",       " Cyan
" "white": "#a89984",      " White

" Bright colors
" "brightBlack": "#928374",    " Bright Black (Gray)
" "brightRed": "#fb4934",      " Bright Red
" "brightGreen": "#b8bb26",    " Bright Green
" "brightYellow": "#fabd2f",   " Bright Yellow
" "brightBlue": "#83a598",     " Bright Blue
" "brightPurple": "#d3869b",   " Bright Magenta (Pink)
" "brightCyan": "#8ec07c",     " Bright Cyan
" "brightWhite": "#ebdbb2",    " Bright White

