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
" If you didn't intend to clobber 'r' (replace char), remove this:
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
--  DIAGNOSTIC DEDUPLICATION (MUST BE FIRST)
-- ------------------------------------------------------------------
local function setup_diagnostic_dedup()
  local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
  
  vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    if not result or not result.diagnostics then
      return original_handler(err, result, ctx, config)
    end
    
    -- Create a map to track unique diagnostics per buffer
    local seen = {}
    local filtered_diagnostics = {}
    
    for _, diagnostic in ipairs(result.diagnostics) do
      local range = diagnostic.range
      local key = string.format("%s|%d|%d:%d-%d:%d",
        diagnostic.message or "",
        diagnostic.severity or vim.diagnostic.severity.ERROR,
        range.start.line,
        range.start.character,
        range["end"].line,
        range["end"].character
      )
      
      if not seen[key] then
        seen[key] = true
        table.insert(filtered_diagnostics, diagnostic)
      end
    end
    
    -- Update result with filtered diagnostics
    local filtered_result = vim.tbl_deep_extend("force", result, {
      diagnostics = filtered_diagnostics
    })
    
    return original_handler(err, filtered_result, ctx, config)
  end
end

-- Set up deduplication before any LSP servers
setup_diagnostic_dedup()

-- ------------------------------------------------------------------
--  LSP & COMPLETION
-- ------------------------------------------------------------------
local lspconfig       = require('lspconfig')
local cmp             = require('cmp')
local capabilities    = require('cmp_nvim_lsp').default_capabilities()

local function on_attach(client, bufnr)
  local o = { buffer = bufnr, silent = true }
  vim.keymap.set('n','gd', vim.lsp.buf.definition,      o)
  vim.keymap.set('n','gi', vim.lsp.buf.implementation,  o)
  vim.keymap.set('n','gr', vim.lsp.buf.references,      o)
  vim.keymap.set('n','<leader>ca', vim.lsp.buf.code_action, o)
end

-- ------------------------------------------------------------------
--  MASON (INSTALL ONLY) — NO AUTO-SETUP
-- ------------------------------------------------------------------
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'clangd', 'hls' },
  automatic_installation = false,
})

-- Track which servers are already set up to prevent duplicates
local setup_servers = {}

local function safe_setup_server(server_name, config)
  if setup_servers[server_name] then
    return -- Already set up
  end
  setup_servers[server_name] = true
  lspconfig[server_name].setup(config)
end

-- Manually set up only the servers we want, once.
safe_setup_server('clangd', {
  on_attach    = on_attach,
  capabilities = capabilities,
})

-- ------------------------------------------------------------------
--  LANGUAGE-SPECIFIC OVERRIDES
-- ------------------------------------------------------------------
-- Scala (metals)
local metals      = require('metals')
local metals_cfg  = metals.bare_config()
metals_cfg.capabilities = capabilities
metals_cfg.settings     = { showImplicitArguments = true }
metals_cfg.on_attach    = on_attach

vim.api.nvim_create_autocmd('FileType', {
  pattern  = { 'scala', 'sbt' },
  callback = function() 
    -- Only initialize if not already attached
    local buf = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_active_clients({ bufnr = buf })
    for _, client in pairs(clients) do
      if client.name == 'metals' then
        return -- Already attached
      end
    end
    metals.initialize_or_attach(metals_cfg) 
  end,
})

-- Haskell (hls) — ensure only one client attaches
safe_setup_server('hls', {
  cmd = { "haskell-language-server-wrapper", "--lsp" },
  cmd_env = { PATH = vim.fn.expand("~/.ghcup/bin") .. ":" .. vim.env.PATH },
  on_attach = function(client, bufnr)
    -- Check for duplicate hls clients and stop them
    local active_clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    local hls_count = 0
    for _, c in pairs(active_clients) do
      if c.name == 'hls' then
        hls_count = hls_count + 1
        if hls_count > 1 and c.id ~= client.id then
          vim.schedule(function() c.stop() end)
          return
        end
      end
    end
    on_attach(client, bufnr)
  end,
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
--  DIAGNOSTIC CONFIGURATION
-- ------------------------------------------------------------------
local ok, lsp_lines = pcall(require,'lsp_lines')
if ok then
  lsp_lines.setup()
end

vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = ok, -- Only enable if lsp_lines loaded successfully
  severity_sort = true,
  update_in_insert = false, -- Prevent duplicates during typing
  signs = true,
  underline = true,
  float = {
    show_header = true,
    source = 'always',
    border = 'rounded',
  },
})

-- ------------------------------------------------------------------
--  OTHER PLUGINS
-- ------------------------------------------------------------------
require('toggleterm').setup({ 
  size = 15, 
  open_mapping = [[<D-f>]], 
  direction = 'float' 
})

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
--  DIAGNOSTIC COLORS  (very subdued messages; colored signs)
-- ------------------------------------------------------------------
local sign = {
  err  = '#cc241d', -- red (gruvbox)
  warn = '#d79921', -- yellow
  info = '#458588', -- blue
  hint = '#689d6a', -- green
}
local vt = '#7c6f64'        -- gruvbox fg3: muted gray-brown
local underline = '#5a524c' -- darker gray for undercurl

local function set_diag_hl()
  local set = vim.api.nvim_set_hl
  -- virtual text / lsp_lines blocks: all the same muted color
  for _, sev in ipairs({ 'Error','Warn','Info','Hint' }) do
    set(0, 'DiagnosticVirtualText'..sev, { fg = vt })
    set(0, 'LspLines'..sev,              { fg = vt })
    set(0, 'LspLinesVirtualText'..sev,   { fg = vt })
    set(0, 'DiagnosticFloating'..sev,    { fg = vt })
    set(0, 'DiagnosticUnderline'..sev,   { undercurl = true, sp = underline })
  end
  -- signs keep severity color but not screaming-bright
  set(0,'DiagnosticSignError', { fg = sign.err })
  set(0,'DiagnosticSignWarn',  { fg = sign.warn })
  set(0,'DiagnosticSignInfo',  { fg = sign.info })
  set(0,'DiagnosticSignHint',  { fg = sign.hint })
end

set_diag_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_diag_hl })
EOF
