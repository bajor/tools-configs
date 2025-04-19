" Leader is spacebar THIS NEEDS TO BE BEFORE LEADER SHORTCUTS
let mapleader = " "

set cmdheight=2  " Increase the command-line height to 2 lines
set display=lastline  " Ensure long messages are shown completely


" START OF PLUGINS CONFIG
call plug#begin('~/.vim/plugged')


" Gruvbox color scheme for Windows Terminal
Plug 'morhetz/gruvbox'

" Error messagess wrapped
Plug 'Maan2003/lsp_lines.nvim'

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
" ── Darker diagnostic virtual‑text & signs (keep code colours) ─────────────
augroup MyDarkerDiagnostics
  autocmd!
  " Re‑apply every time you :colorscheme
  autocmd ColorScheme * call DarkerDiagnostics()
augroup END

function! DarkerDiagnostics() abort
  " ── virtual text (inline messages) ──────────────────────────────────────
  highlight! DiagnosticVirtualTextError  gui=NONE guifg=#7f1d1d cterm=NONE ctermfg=1
  highlight! DiagnosticVirtualTextWarn   gui=NONE guifg=#7f5e00 cterm=NONE ctermfg=3
  highlight! DiagnosticVirtualTextInfo   gui=NONE guifg=#0f5f87 cterm=NONE ctermfg=4
  highlight! DiagnosticVirtualTextHint   gui=NONE guifg=#00605f cterm=NONE ctermfg=6

  " ── sign‑column icons ───────────────────────────────────────────────────
  highlight! DiagnosticSignError         gui=NONE guifg=#7f1d1d cterm=NONE ctermfg=1
  highlight! DiagnosticSignWarn          gui=NONE guifg=#7f5e00 cterm=NONE ctermfg=3
  highlight! DiagnosticSignInfo          gui=NONE guifg=#0f5f87 cterm=NONE ctermfg=4
  highlight! DiagnosticSignHint          gui=NONE guifg=#00605f cterm=NONE ctermfg=6
endfunction

" Run once on startup
call DarkerDiagnostics()
" ───────────────────────────────────────────────────────────────────────────


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

function! DarkerDiagnostics() abort
  " …paste the 14 highlight! lines from above here…
endfunction

" Run once on startup (otherwise you’d wait for the first ColorScheme event)
call DarkerDiagnostics()



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


require("lsp_lines").setup()
vim.diagnostic.config({
  virtual_text = false,  -- Disable default inline messages
  virtual_lines = true,  -- Enable error messages across multiple lines
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

require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "hls", "gopls" },
}

local lspconfig = require('lspconfig')
lspconfig.hls.setup {}

lspconfig.gopls.setup {
  capabilities = capabilities,
  -- The on_attach function can define keybindings or format-on-save behavior
  on_attach = function(client, bufnr)
    -- Format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("GoFormat", { clear = true }),
      pattern = "*.go",
      callback = function()
        -- Uses the built-in LSP format
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
  -- Gopls-specific settings, e.g. using gofumpt
  settings = {
    gopls = {
      gofumpt = true, -- stricter formatter than gofmt
      usePlaceholders = true,
      completeUnimported = true,
    },
  },
}


EOF

