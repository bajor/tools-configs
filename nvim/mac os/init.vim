" ========================== BASIC SETTINGS ==========================
let mapleader = " "

set cmdheight=2
set display=lastline
set number
set relativenumber
set hidden
set updatetime=300
set signcolumn=yes

" ========================== PLUGINS ==========================
call plug#begin('~/.vim/plugged')

" UI and Themes
Plug 'morhetz/gruvbox'

" LSP and Completion
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'

" Scala
Plug 'scalameta/nvim-metals'

" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Terminal, Comment, Git
Plug 'akinsho/toggleterm.nvim'
Plug 'numToStr/Comment.nvim'
Plug 'lewis6991/gitsigns.nvim'

" Mason LSP manager
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

" Inline diagnostics
Plug 'Maan2003/lsp_lines.nvim'

call plug#end()

" ========================== THEMING ==========================
syntax enable
set background=dark
colorscheme gruvbox

" ========================== KEY MAPPINGS ==========================
nnoremap <silent> <Leader>ff :Telescope find_files<CR>
nnoremap <silent> <C-p> :Telescope live_grep<CR>
nnoremap <silent> <D-p> :Telescope live_grep<CR>
nnoremap <silent> <Leader>fb :Telescope buffers<CR>
nnoremap <silent> <Leader>q :cclose<CR>
nnoremap <silent> <F2> :lua vim.lsp.buf.rename()<CR>

inoremap jk <Esc>
nnoremap <Leader>v :vsplit<CR>
nnoremap <Leader>h <C-w>h
nnoremap <Leader>l <C-w>l
nnoremap r <C-r>
nnoremap <C-n> :nohl<CR>
nnoremap <C-_> :lua require('Comment.api').toggle.linewise.current()<CR>
xnoremap <C-_> :lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>

" ========================== AUTOCOMMANDS ==========================
augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=100}
augroup END

augroup MyDarkerDiagnostics
  autocmd!
  autocmd ColorScheme * call DarkerDiagnostics()
augroup END

function! DarkerDiagnostics() abort
  highlight! DiagnosticVirtualTextError  gui=NONE guifg=#7f1d1d
  highlight! DiagnosticVirtualTextWarn   gui=NONE guifg=#7f5e00
  highlight! DiagnosticVirtualTextInfo   gui=NONE guifg=#0f5f87
  highlight! DiagnosticVirtualTextHint   gui=NONE guifg=#00605f
  highlight! DiagnosticSignError         gui=NONE guifg=#7f1d1d
  highlight! DiagnosticSignWarn          gui=NONE guifg=#7f5e00
  highlight! DiagnosticSignInfo          gui=NONE guifg=#0f5f87
  highlight! DiagnosticSignHint          gui=NONE guifg=#00605f
endfunction
call DarkerDiagnostics()

" ========================== LUA CONFIG ==========================
lua << EOF
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")
local cmp = require("cmp")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Attach LSP keybindings
local function on_attach(client, bufnr)
  local opt = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opt)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opt)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opt)
  vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opt)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opt)
end

-- Mason setup
require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "hls", "gopls", "pyright" }
}

-- Safe setup_handlers fallback
local mason_lspconfig = require("mason-lspconfig")
if mason_lspconfig.setup_handlers then
  mason_lspconfig.setup_handlers({
    function(server)
      lspconfig[server].setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }
    end
  })
else
  for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
    lspconfig[server].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end
end

-- Scala (metals)
local metals = require("metals")
local metals_config = metals.bare_config()
metals_config.capabilities = capabilities
metals_config.settings = { showImplicitArguments = true }
metals_config.init_options = { statusBarProvider = "on" }

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt" },
  callback = function()
    metals.initialize_or_attach(metals_config)
  end,
})

-- Haskell (hls)
lspconfig.hls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = util.root_pattern("hie.yaml", "stack.yaml", "cabal.project", "package.yaml", "*.cabal", ".git"),
  settings = {
    haskell = {
      formattingProvider = "ormolu",
      checkParents = "on-save"
    }
  }
}

-- Golang
lspconfig.gopls.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("GoFormat", { clear = true }),
      pattern = "*.go",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = true,
      completeUnimported = true,
    },
  },
}

-- Completion
cmp.setup({
  mapping = {
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item() else fallback() end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item() else fallback() end
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

-- ToggleTerm
require("toggleterm").setup {
  size = 15,
  open_mapping = [[<D-f>]],
  direction = "float",
  close_on_exit = true,
  shell = vim.o.shell,
}

-- lsp_lines
local ok, lsp_lines = pcall(require, "lsp_lines")
if ok then
  lsp_lines.setup()
  vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
end

-- Comment.nvim
require("Comment").setup()

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '-' },
    topdelete = { text = 'T' },
    changedelete = { text = 'C' },
  },
  watch_gitdir = { interval = 100, follow_files = true },
  update_debounce = 100,
  current_line_blame = false,
}
EOF

