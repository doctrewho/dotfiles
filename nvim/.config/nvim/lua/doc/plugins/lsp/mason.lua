-- mason.lua
return {
  -- 1) Mason core
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate", -- keep registries fresh
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- 2) LSP server bridge for Mason
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- Mason will ensure these LSP servers are installed
      ensure_installed = {
        "lua_ls",
        "pyright",
        "ansiblels",
      },
      -- Optional: automatically install configured servers via lspconfig
      automatic_installation = true,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      -- (Optional) set up servers via lspconfig here or elsewhere
      -- local lspconfig = require("lspconfig")
      -- for _, server in ipairs(opts.ensure_installed or {}) do
      --   lspconfig[server].setup({})
      -- end
    end,
  },

  -- 3) Non-LSP tools (formatters/linters/debuggers)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "prettier",
        "stylua",
        "isort",
        "black",
        "pylint",
        "ansible-lint",
        "yamllint",
      },
      -- Optional quality-of-life flags:
      run_on_start = true, -- install missing tools on startup
      start_delay = 3000, -- ms delay before running on start
      debounce_hours = 24, -- don't run more than once a day
      auto_update = false, -- set true if you prefer auto-updates
    },
  },
}
