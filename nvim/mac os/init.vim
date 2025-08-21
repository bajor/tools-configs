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
nnoremap <silent> <Leader>n :nohl<CR>

inoremap jk <Esc>
nnoremap <Leader>v :vsplit<CR>
nnoremap <Leader>h <C-w>h
nnoremap <Leader>l <C-w>l
nnoremap r <C-r>
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
local mlsp = require('mason-lspconfig')
mlsp.setup({ ensure_installed = { 'hls', 'clangd' } })

mlsp.setup_handlers({
  -- default for all servers EXCEPT ones you override
  function(server)
    if server == 'hls' then return end
    lspconfig[server].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end,

  -- HLS override
  ['hls'] = function()
    lspconfig.hls.setup({
      cmd = { "haskell-language-server-wrapper", "--lsp" },
      cmd_env = { PATH = vim.fn.expand("~/.ghcup/bin") .. ":" .. vim.env.PATH },
      on_attach    = on_attach,
      capabilities = capabilities,
      root_dir     = lspconfig.util.root_pattern(
                       'hie.yaml','stack.yaml','cabal.project',
                       'package.yaml','*.cabal','.git'),
      settings     = {
        haskell = {
          formattingProvider = 'ormolu',
          checkParents       = 'on-save',
        },
      },
    })
  end,
})

-- ------------------------------------------------------------------
--  LANGUAGE-SPECIFIC: Scala (metals)
-- ------------------------------------------------------------------
local metals      = require('metals')
local metals_cfg  = metals.bare_config()
metals_cfg.capabilities = capabilities
metals_cfg.settings     = { showImplicitArguments = true }
vim.api.nvim_create_autocmd('FileType', {
  pattern  = { 'scala', 'sbt' },
  callback = function() metals.initialize_or_attach(metals_cfg) end,
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
--  DIAGNOSTIC COLORS  (apply now + on colorscheme change)
-- ------------------------------------------------------------------
local function set_diag_hls()
  local set = vim.api.nvim_set_hl
  local c = {
    err  = '#7f1d1d',
    warn = '#7f5e00',
    info = '#0f5f87',
    hint = '#00605f',
  }

  -- signs / virtual text / floating
  set(0,'DiagnosticVirtualTextError',{fg=c.err})
  set(0,'DiagnosticVirtualTextWarn', {fg=c.warn})
  set(0,'DiagnosticVirtualTextInfo', {fg=c.info})
  set(0,'DiagnosticVirtualTextHint', {fg=c.hint})
  set(0,'DiagnosticSignError',       {fg=c.err})
  set(0,'DiagnosticSignWarn',        {fg=c.warn})
  set(0,'DiagnosticSignInfo',        {fg=c.info})
  set(0,'DiagnosticSignHint',        {fg=c.hint})
  set(0,'DiagnosticFloatingError',   {fg=c.err})
  set(0,'DiagnosticFloatingWarn',    {fg=c.warn})
  set(0,'DiagnosticFloatingInfo',    {fg=c.info})
  set(0,'DiagnosticFloatingHint',    {fg=c.hint})

  -- undercurls in code
  set(0,'DiagnosticUnderlineError', {undercurl=true, sp=c.err})
  set(0,'DiagnosticUnderlineWarn',  {undercurl=true, sp=c.warn})
  set(0,'DiagnosticUnderlineInfo',  {undercurl=true, sp=c.info})
  set(0,'DiagnosticUnderlineHint',  {undercurl=true, sp=c.hint})
end

-- apply immediately (colorscheme already set earlier)
set_diag_hls()
-- re-apply on future colorscheme changes
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_diag_hls })

EOF

