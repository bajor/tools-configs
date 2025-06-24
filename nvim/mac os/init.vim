" ========================== BASIC SETTINGS ==========================
let mapleader = " "

set termguicolors
set cmdheight=2
set display=lastline
set hidden
set updatetime=300
set signcolumn=yes

" ========================== PLUGINS ==========================
call plug#begin('~/.vim/plugged')
  " UI / theme
  Plug 'morhetz/gruvbox'

  " LSP & completion
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'

  " Scala
  Plug 'scalameta/nvim-metals'

  " Telescope
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'

  " Terminal, comment, git
  Plug 'akinsho/toggleterm.nvim'
  Plug 'numToStr/Comment.nvim'
  Plug 'lewis6991/gitsigns.nvim'

  " Mason (LSP installer)
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'

  " Inline diagnostics
  Plug 'Maan2003/lsp_lines.nvim'

  " Treesitter for C highlighting
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()

" ========================== THEMING ==========================
syntax enable
set background=dark
colorscheme gruvbox

" ========================== KEY MAPPINGS ==========================
nnoremap <silent> <Leader>ff :Telescope find_files<CR>
nnoremap <silent> <D-p>      :Telescope live_grep<CR>
nnoremap <silent> <Leader>fb :Telescope buffers<CR>
nnoremap <silent> <Leader>q  :cclose<CR>
nnoremap <silent> <F2>       :lua vim.lsp.buf.rename()<CR>

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

" format C on save
augroup CFormat
  autocmd!
  autocmd BufWritePre *.c,*.h lua vim.lsp.buf.format({ async = false })
augroup END

" ========================== LUA CONFIG ==========================
lua << EOF
-- ------------------------------------------------------------------
--  LSP & COMPLETION
-- ------------------------------------------------------------------
local lspconfig       = require('lspconfig')
local cmp             = require('cmp')
local capabilities    = require('cmp_nvim_lsp').default_capabilities()

local function on_attach(_, bufnr)
  local o = { buffer = bufnr, silent = true }
  vim.keymap.set('n','gd', vim.lsp.buf.definition,      o)
  vim.keymap.set('n','gi', vim.lsp.buf.implementation,  o)
  vim.keymap.set('n','gr', vim.lsp.buf.references,      o)
  vim.keymap.set('n','<leader>ca', vim.lsp.buf.code_action, o)
end

-- ------------------------------------------------------------------
--  MASON & LSP-INSTALLER
-- ------------------------------------------------------------------
require('mason').setup()

local mlsp = require('mason-lspconfig')   -- create the variable ONCE
mlsp.setup({ ensure_installed = { 'hls', 'clangd' } })

-- Newer mason-lspconfig exposes :setup_handlers(); older ones do not.
if mlsp.setup_handlers then
  mlsp.setup_handlers({
    function(server)
      lspconfig[server].setup({ on_attach = on_attach, capabilities = capabilities })
    end,
  })
else
  for _, server in ipairs(mlsp.get_installed_servers()) do
    lspconfig[server].setup({ on_attach = on_attach, capabilities = capabilities })
  end
end

-- ------------------------------------------------------------------
--  LANGUAGE-SPECIFIC OVERRIDES
-- ------------------------------------------------------------------
-- Scala (metals)
local metals      = require('metals')
local metals_cfg  = metals.bare_config()
metals_cfg.capabilities = capabilities
metals_cfg.settings     = { showImplicitArguments = true }
vim.api.nvim_create_autocmd('FileType', {
  pattern  = { 'scala', 'sbt' },
  callback = function() metals.initialize_or_attach(metals_cfg) end,
})

-- Haskell (hls) – extra root patterns & settings
lspconfig.hls.setup({
  on_attach    = on_attach,
  capabilities = capabilities,
  root_dir     = lspconfig.util.root_pattern(
                   'hie.yaml','stack.yaml','cabal.project',
                   'package.yaml','*.cabal','.git'),
  settings     = { haskell = { formattingProvider = 'ormolu', checkParents = 'on-save' } }
})

-- ------------------------------------------------------------------
--  TREESITTER (C syntax highlighting)
-- ------------------------------------------------------------------
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'c', 'lua', 'vimdoc', 'bash' },
  highlight        = { enable = true },
})

-- ------------------------------------------------------------------
--  COMPLETION
-- ------------------------------------------------------------------
cmp.setup({
  mapping = {
    ['<Tab>']   = cmp.mapping(function(fb)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fb()
      end
    end, { 'i','s' }),
    ['<S-Tab>'] = cmp.mapping(function(fb)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fb()
      end
    end, { 'i','s' }),
    ['<CR>']    = cmp.mapping.confirm({ select = true }),
    ['<Up>']    = cmp.mapping.select_prev_item(),
    ['<Down>']  = cmp.mapping.select_next_item(),
  },
  sources = { { name='nvim_lsp' }, { name='buffer' }, { name='path' } },
})

-- ------------------------------------------------------------------
--  OTHER PLUGINS
-- ------------------------------------------------------------------
require('toggleterm').setup({ size = 15, open_mapping = [[<D-f>]], direction = 'float' })

local ok, lsp_lines = pcall(require,'lsp_lines')
if ok then
  lsp_lines.setup()
  vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
end

require('Comment').setup()

require('gitsigns').setup({
  signs = {
    add         = { text = '+' },
    change      = { text = '~' },
    delete      = { text = '-' },
    topdelete   = { text = 'T' },
    changedelete= { text = 'C' },
  },
  watch_gitdir    = { interval = 100, follow_files = true },
  update_debounce = 100,
})

-- ------------------------------------------------------------------
--  DIAGNOSTIC COLORS  (dark palette)
-- ------------------------------------------------------------------
local dark = {
  err  = '#7f1d1d',
  warn = '#7f5e00',
  info = '#0f5f87',
  hint = '#00605f',
}
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    local set = vim.api.nvim_set_hl
    set(0,'DiagnosticVirtualTextError',{fg=dark.err})
    set(0,'DiagnosticVirtualTextWarn', {fg=dark.warn})
    set(0,'DiagnosticVirtualTextInfo', {fg=dark.info})
    set(0,'DiagnosticVirtualTextHint', {fg=dark.hint})
    set(0,'DiagnosticSignError',       {fg=dark.err})
    set(0,'DiagnosticSignWarn',        {fg=dark.warn})
    set(0,'DiagnosticSignInfo',        {fg=dark.info})
    set(0,'DiagnosticSignHint',        {fg=dark.hint})
  end
})
EOF

