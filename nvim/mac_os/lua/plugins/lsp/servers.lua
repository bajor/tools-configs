-- LSP Server configurations
local M = {}

function M.setup(capabilities)
  -- Clangd (C/C++)
  vim.lsp.config.clangd = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    root_markers = { '.clangd', 'compile_commands.json', 'compile_flags.txt', '.git' },
    capabilities = capabilities,
  }
  vim.lsp.enable('clangd')

  -- HLS (Haskell)
  vim.lsp.config.hls = {
    cmd = { 'haskell-language-server-wrapper', '--lsp' },
    filetypes = { 'haskell', 'lhaskell' },
    root_markers = { 'hie.yaml', 'stack.yaml', 'cabal.project', '*.cabal', 'package.yaml', '.git' },
    capabilities = capabilities,
    settings = {
      haskell = {
        formattingProvider = 'ormolu',
        checkProject = true,
      },
    },
  }
  vim.lsp.enable('hls')

  -- Gopls (Go)
  vim.lsp.config.gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.work', 'go.mod', '.git' },
    capabilities = capabilities,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          shadow = true,
          nilness = true,
          unusedwrite = true,
          useany = true,
        },
        staticcheck = true,
        gofumpt = true,
        usePlaceholders = true,
        completeUnimported = true,
        semanticTokens = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  }
  vim.lsp.enable('gopls')

  -- Elixir-LS
  vim.lsp.config.elixirls = {
    cmd = { 'elixir-ls' },
    filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
    root_markers = { 'mix.exs', '.git' },
    capabilities = capabilities,
    settings = {
      elixirLS = {
        dialyzerEnabled = true,
        fetchDeps = false,
        enableTestLenses = true,
        suggestSpecs = true,
      },
    },
  }
  vim.lsp.enable('elixirls')

  -- Pyright (Python)
  vim.lsp.config.pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
    capabilities = capabilities,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = 'workspace',
          typeCheckingMode = 'basic',
        },
      },
    },
  }
  vim.lsp.enable('pyright')

  -- Ruff (Python linter/formatter)
  vim.lsp.config.ruff = {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', 'setup.py', '.git' },
    capabilities = capabilities,
    settings = {
      organizeImports = true,
      fixAll = true,
    },
  }
  vim.lsp.enable('ruff')

  -- OCaml-LSP
  vim.lsp.config.ocamllsp = {
    cmd = { 'ocamllsp' },
    filetypes = { 'ocaml', 'ocaml.menhir', 'ocaml.interface', 'ocaml.ocamllex', 'reason', 'dune' },
    root_markers = { 'dune-project', 'dune-workspace', '.opam', 'esy.json', 'package.json', '.git' },
    capabilities = capabilities,
    settings = {
      codelens = { enable = true },
      inlayHints = { enable = true },
    },
    get_language_id = function(_, filetype)
      local map = {
        ['ocaml.interface'] = 'ocaml.interface',
        ['ocaml.ocamllex'] = 'ocaml.ocamllex',
        ['ocaml.menhir'] = 'ocaml.menhir',
        ['reason'] = 'reason',
      }
      return map[filetype] or 'ocaml'
    end,
  }
  vim.lsp.enable('ocamllsp')

  -- Scala Metals (special setup)
  M.setup_metals(capabilities)
end

function M.setup_metals(capabilities)
  local ok, metals = pcall(require, 'metals')
  if not ok then return end

  local metals_cfg = metals.bare_config()

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

  metals_cfg.capabilities = capabilities

  metals_cfg.on_attach = function(client, bufnr)
    pcall(require('metals').setup_dap)
  end

  -- Auto-start for Scala files
  local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "scala", "sbt", "java" },
    group = group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients({ bufnr = buf })
      for _, client in pairs(clients) do
        if client.name == 'metals' then return end
      end
      require('metals').initialize_or_attach(metals_cfg)
    end,
  })

  -- DAP setup for Scala
  M.setup_scala_dap()
end

function M.setup_scala_dap()
  local ok_dap, dap = pcall(require, 'dap')
  if not ok_dap then return end

  dap.configurations.scala = {
    {
      type = "scala",
      request = "launch",
      name = "Run or Test Target",
      metals = { runType = "runOrTestFile" },
    },
    {
      type = "scala",
      request = "launch",
      name = "Test Target",
      metals = { runType = "testTarget" },
    },
  }

  local ok_ui, dapui = pcall(require, 'dapui')
  if not ok_ui then return end

  dapui.setup({
    layouts = {
      {
        elements = { 'scopes', 'breakpoints', 'stacks', 'watches' },
        size = 40,
        position = 'left',
      },
      {
        elements = { 'repl', 'console' },
        size = 10,
        position = 'bottom',
      },
    },
  })

  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
end

return M
