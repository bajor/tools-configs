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

  " LSP & completion
  Plug 'neovim/nvim-lspconfig'
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
  Plug 'lewis6991/gitsigns.nvim'

  " Mason (LSP installer)
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'

  " Inline diagnostics
  Plug 'Maan2003/lsp_lines.nvim'

  " Treesitter for better highlighting
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-textobjects'

  " Scala specific tools
  Plug 'ckipp01/nvim-jvmopts'
  Plug 'ray-x/lsp_signature.nvim'

  " Copilot
  Plug 'github/copilot.vim'
  Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
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

" NvimTree toggle with Cmd+Shift+E
nnoremap <silent> <D-S-e> :NvimTreeToggle<CR>

" Copilot Chat with Cmd+Shift+I
nnoremap <silent> <D-S-i> :lua require('CopilotChat').toggle()<CR>

" Jump list navigation (go back/forward after gd)
" Cmd+[ to go back, Cmd+] to go forward (macOS) - like browser navigation
nnoremap <silent> <D-[> <C-o>
nnoremap <silent> <D-]> <C-i>
" Alternative: Using Alt/Option + arrows (like browser navigation)
nnoremap <silent> <M-Left> <C-o>
nnoremap <silent> <M-Right> <C-i>
" Alternative: Using Alt + h/l
nnoremap <silent> <M-h> <C-o>
nnoremap <silent> <M-l> <C-i>
" Alternative: Using brackets
nnoremap <silent> [b <C-o>
nnoremap <silent> ]b <C-i>

inoremap jk <Esc>
nnoremap <Leader>v :vsplit<CR>
nnoremap <Leader>l <C-w>l
nnoremap <Leader>h <C-w>h
" If you didn't intend to clobber 'r' (replace char), remove this:
nnoremap r <C-r>

" Cmd+/ for commenting
nnoremap <D-/> :lua require('Comment.api').toggle.linewise.current()<CR>
xnoremap <D-/> :lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>

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
    
    local filtered_result = vim.tbl_deep_extend("force", result, {
      diagnostics = filtered_diagnostics
    })
    
    return original_handler(err, filtered_result, ctx, config)
  end
end

setup_diagnostic_dedup()

-- ------------------------------------------------------------------
--  NVIM-TREE CONFIGURATION
-- ------------------------------------------------------------------
local ok_nvim_tree, nvim_tree = pcall(require, 'nvim-tree')
if ok_nvim_tree then
  -- disable netrw at the very start of your init.vim
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  nvim_tree.setup({
    view = {
      side = "right",
    },
  })
end

-- ------------------------------------------------------------------
--  LSP & COMPLETION
-- ------------------------------------------------------------------
local lspconfig       = require('lspconfig')
local cmp             = require('cmp')
local has_luasnip, luasnip = pcall(require, 'luasnip')
local capabilities    = require('cmp_nvim_lsp').default_capabilities()

-- Keep original on_attach with just the existing mappings
local function on_attach(client, bufnr)
  local o = { buffer = bufnr, silent = true }
  vim.keymap.set('n','gd', vim.lsp.buf.definition,      o)
  vim.keymap.set('n','gi', vim.lsp.buf.implementation,  o)
  vim.keymap.set('n','gr', vim.lsp.buf.references,      o)
  vim.keymap.set('n','<leader>ca', vim.lsp.buf.code_action, o)
  
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  
  -- Signature help setup
  require('lsp_signature').on_attach({
    bind = true,
    handler_opts = {
      border = "rounded"
    }
  }, bufnr)
end

-- ------------------------------------------------------------------
--  MASON (INSTALL ONLY)
-- ------------------------------------------------------------------
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'clangd', 'hls' },
  automatic_installation = false,
})

local setup_servers = {}

local function safe_setup_server(server_name, config)
  if setup_servers[server_name] then
    return
  end
  setup_servers[server_name] = true
  lspconfig[server_name].setup(config)
end

safe_setup_server('clangd', {
  on_attach    = on_attach,
  capabilities = capabilities,
})

-- ------------------------------------------------------------------
--  SCALA METALS CONFIGURATION
-- ------------------------------------------------------------------
local metals      = require('metals')
local metals_cfg  = metals.bare_config()

-- Metals settings optimized for Scala 3
metals_cfg.settings = {
  showImplicitArguments = true,
  showImplicitConversionsAndClasses = true,
  showInferredType = true,
  superMethodLensesEnabled = true,
  enableSemanticHighlighting = false,
  excludedPackages = {
    "akka.actor.typed.javadsl",
    "com.github.swagger.akka.javadsl",
    "akka.stream.javadsl",
    "akka.http.javadsl"
  },
  fallbackScalaVersion = "3.3.1",
  serverVersion = "latest.snapshot",
  serverProperties = {
    "-Xmx2G",
    "-XX:+UseG1GC",
    "-XX:MaxGCPauseMillis=100",
    "-XX:GCTimeRatio=4",
    "-XX:+UseStringDeduplication"
  }
}

metals_cfg.init_options = {
  statusBarProvider = "on",
  inputBoxProvider = true,
  quickPickProvider = true,
  executeClientCommandProvider = true,
  decorationProvider = true,
  inlineDecorationProvider = true,
  didFocusProvider = true,
  slowTaskProvider = true,
  debuggingProvider = true,
  treeViewProvider = true
}

metals_cfg.capabilities = require('cmp_nvim_lsp').default_capabilities()

metals_cfg.on_attach = function(client, bufnr)
  on_attach(client, bufnr)
  
  local metals_status_update_cmd = function()
    local status = vim.api.nvim_eval("g:metals_status")
    require('lualine').refresh()
  end
  
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MetalsStatus',
    callback = metals_status_update_cmd
  })
  
  local o = { buffer = bufnr, silent = true }
  vim.keymap.set('n', '<leader>ws', function() metals.hover_worksheet() end, o)
  vim.keymap.set('n', '<leader>tt', function() metals.tvp() end, o)
  vim.keymap.set('n', '<leader>tr', function() metals.reveal_in_tree() end, o)
  vim.keymap.set('n', '<leader>mc', function() metals.commands() end, o)
  
  local dap_available, dap = pcall(require, 'dap')
  if dap_available then
    metals.setup_dap()
    local dapui_available, dapui = pcall(require, 'dapui')
    if dapui_available then
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end
      
      vim.keymap.set('n', '<F5>',      function() dap.continue() end, o)
      vim.keymap.set('n', '<F10>',     function() dap.step_over() end, o)
      vim.keymap.set('n', '<F11>',     function() dap.step_into() end, o)
      vim.keymap.set('n', '<S-F11>',   function() dap.step_out() end, o)
      vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, o)
    end
  end
end

metals_cfg.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    virtual_text = false,
  }
)

local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt" },
  callback = function()
    metals.initialize_or_attach(metals_cfg)
  end,
  group = nvim_metals_group,
})

vim.g.metals_status = ""
vim.api.nvim_create_autocmd("User", {
  pattern = "MetalsStatus",
  callback = function(ev)
    vim.g.metals_status = ev.data or ""
  end,
})

-- ------------------------------------------------------------------
--  HASKELL LSP CONFIGURATION
-- ------------------------------------------------------------------
safe_setup_server('hls', {
  on_attach = function(client, bufnr)
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
--  TREESITTER CONFIGURATION
-- ------------------------------------------------------------------
require('nvim-treesitter.configs').setup({
  ensure_installed = { 'c', 'lua', 'vimdoc', 'bash', 'scala', 'java', 'haskell' },
  highlight        = { 
    enable = true,
    additional_vim_regex_highlighting = { 'scala' }
  },
  indent = { enable = true },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
  },
})

-- ------------------------------------------------------------------
--  ENHANCED COMPLETION
-- ------------------------------------------------------------------
cmp.setup({
  snippet = {
    expand = function(args)
      if has_luasnip then
        luasnip.lsp_expand(args.body)
      else
        -- Fallback to basic snippet expansion
        vim.snippet.expand(args.body)
      end
    end,
  },
  mapping = {
    ['<Tab>']   = cmp.mapping(function(fb)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_luasnip and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fb()
      end
    end, { 'i','s' }),
    ['<S-Tab>'] = cmp.mapping(function(fb)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif has_luasnip and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fb()
      end
    end, { 'i','s' }),
    ['<CR>']    = cmp.mapping.confirm({ select = true }),
    ['<Up>']    = cmp.mapping.select_prev_item(),
    ['<Down>']  = cmp.mapping.select_next_item(),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip', max_item_count = 5 },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  }),
  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
      })[entry.source.name]
      return vim_item
    end
  },
  experimental = {
    ghost_text = true,
  },
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
  virtual_lines = ok,
  severity_sort = true,
  update_in_insert = false,
  signs = true,
  underline = true,
  float = {
    show_header = true,
    source = 'always',
    border = 'rounded',
    focusable = false,
  },
})

-- ------------------------------------------------------------------
--  TELESCOPE CONFIGURATION
-- ------------------------------------------------------------------
local telescope = require('telescope')

telescope.setup({
  defaults = {
    file_ignore_patterns = { "node_modules", ".git", "target", ".bloop", ".metals" },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

telescope.load_extension('fzf')

-- ------------------------------------------------------------------
--  COPILOT CHAT CONFIGURATION
-- ------------------------------------------------------------------
local ok_copilot_chat, copilot_chat = pcall(require, 'CopilotChat')
if ok_copilot_chat then
  -- Set highlights BEFORE setup
  local gruvbox_bg = '#282828'
  local gruvbox_fg = '#ebdbb2'
  local gruvbox_border = '#928374'
  
  vim.api.nvim_set_hl(0, 'CopilotChatNormal', { bg = gruvbox_bg, fg = gruvbox_fg })
  vim.api.nvim_set_hl(0, 'CopilotChatBorder', { bg = gruvbox_bg, fg = gruvbox_border })
  vim.api.nvim_set_hl(0, 'FloatBorder', { bg = gruvbox_bg, fg = gruvbox_border })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = gruvbox_bg, fg = gruvbox_fg })
  
  copilot_chat.setup({
    window = {
      layout = 'float',
      width = 0.8,
      height = 0.6,
      relative = 'editor',
      row = 2,
      border = 'rounded',
    },
  })
end

-- ------------------------------------------------------------------
--  OTHER PLUGINS
-- ------------------------------------------------------------------
local ok_toggleterm, toggleterm = pcall(require, 'toggleterm')
if ok_toggleterm then
  toggleterm.setup({ 
    size = 15, 
    open_mapping = [[<D-f>]], 
    direction = 'float',
    float_opts = {
      border = 'curved',
    },
  })
end

local ok_comment, comment = pcall(require, 'Comment')
if ok_comment then
  comment.setup()
end

local ok_gitsigns, gitsigns = pcall(require, 'gitsigns')
if ok_gitsigns then
  gitsigns.setup({
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
end

local ok_lualine, lualine = pcall(require, 'lualine')
if ok_lualine then
  lualine.setup({
    options = {
      theme = 'gruvbox',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {'filename'},
      lualine_x = {
        'g:metals_status',
        'encoding',
        'fileformat',
        'filetype'
      },
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
  })
end

local ok_devicons, devicons = pcall(require, 'nvim-web-devicons')
if ok_devicons then
  devicons.setup({
    override = {
      scala = {
        icon = "",
        color = "#cc3e44",
        cterm_color = "167",
        name = "Scala"
      }
    }
  })
end

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
