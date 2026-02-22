return {
  "neovim/nvim-lspconfig",
  event = { "VeryLazy", "BufReadPre", "BufNewFile" },

  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },

  config = function()
    ---------------------------------------------------------------------------
    -- Load ensure_installed list from servers/install-these-servers
    ---------------------------------------------------------------------------
    local servers_file = vim.fn.stdpath("config") .. "/lua/doc/plugins/lsp/servers/install-these-servers"

    local function read_list()
      if vim.fn.filereadable(servers_file) ~= 1 then
        return {}
      end
      local lines = {}
      for _, line in ipairs(vim.fn.readfile(servers_file)) do
        line = vim.trim(line)
        if line ~= "" and not line:match("^#") then
          table.insert(lines, line)
        end
      end
      return lines
    end

    local function write_list(tbl)
      vim.fn.writefile(tbl, servers_file)
    end

    local ensure_list = read_list()

    ---------------------------------------------------------------------------
    -- Mason + Mason-LSPConfig
    ---------------------------------------------------------------------------
    local mason = require("mason")
    mason.setup()

    local mason_lspconfig = require("mason-lspconfig")
    mason_lspconfig.setup({
      ensure_installed = ensure_list,
      automatic_installation = false,
    })

    ---------------------------------------------------------------------------
    -- LSP keymaps
    ---------------------------------------------------------------------------
    local keymap = vim.keymap
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Prev diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Hover"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    ---------------------------------------------------------------------------
    -- Diagnostic signs
    ---------------------------------------------------------------------------
    local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    ---------------------------------------------------------------------------
    -- Shared capabilities + utils
    ---------------------------------------------------------------------------
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local util = require("lspconfig.util")

    local function coerce_path(x)
      if type(x) == "number" then
        x = vim.api.nvim_buf_get_name(x)
      end
      if not x or x == "" then
        x = vim.api.nvim_buf_get_name(0)
      end
      return x
    end

    local function safe_git_root(x)
      x = coerce_path(x)
      return util.find_git_ancestor(x)
    end

    local function or_dirname(x)
      x = coerce_path(x)
      return util.path.dirname(x)
    end

    ---------------------------------------------------------------------------
    -- Commands: LspAdd, LspRemove, LspValidateServers
    ---------------------------------------------------------------------------

    -- :LspAdd <server>
    vim.api.nvim_create_user_command("LspAdd", function(opts)
      local server = vim.trim(opts.args)
      if server == "" then
        print("No server name provided")
        return
      end

      local list = read_list()
      for _, s in ipairs(list) do
        if s == server then
          print("Server already listed: " .. server)
          return
        end
      end

      table.insert(list, server)
      write_list(list)
      print("Added server: " .. server)
    end, {
      nargs = 1,
      complete = function()
        return require("mason-lspconfig").get_available_servers()
      end,
    })

    -- :LspRemove <server>
    vim.api.nvim_create_user_command("LspRemove", function(opts)
      local server = vim.trim(opts.args)
      if server == "" then
        print("No server name provided")
        return
      end

      local list = read_list()
      local new = {}
      local removed = false

      for _, s in ipairs(list) do
        if s == server then
          removed = true
        else
          table.insert(new, s)
        end
      end

      if not removed then
        print("Server not found: " .. server)
        return
      end

      write_list(new)
      print("Removed server: " .. server)
    end, {
      nargs = 1,
      complete = function()
        return read_list()
      end,
    })

    -- :LspValidateServers
    vim.api.nvim_create_user_command("LspValidateServers", function()
      local list = read_list()

      local dir = vim.fn.stdpath("config") .. "/lua/doc/plugins/lsp/servers"
      local paths = vim.fn.globpath(dir, "*.lua", false, true)
      local configs = {}

      for _, path in ipairs(paths) do
        local name = vim.fn.fnamemodify(path, ":t:r")
        configs[name] = true
      end

      print("Validating LSP server configuration…")

      for _, server in ipairs(list) do
        if not configs[server] then
          print("⚠️  Listed but missing config file: " .. server)
        end
      end

      for cfg, _ in pairs(configs) do
        local found = false
        for _, s in ipairs(list) do
          if s == cfg then
            found = true
            break
          end
        end
        if not found then
          print("⚠️  Config file exists but not listed: " .. cfg)
        end
      end

      print("Validation complete.")
    end, {})

    ---------------------------------------------------------------------------
    -- AUTO-DISCOVER SERVER FILES
    ---------------------------------------------------------------------------
    local function list_servers()
      local dir = vim.fn.stdpath("config") .. "/lua/doc/plugins/lsp/servers"
      local paths = vim.fn.globpath(dir, "*.lua", false, true)
      local servers = {}

      for _, path in ipairs(paths) do
        local name = vim.fn.fnamemodify(path, ":t:r")
        table.insert(servers, name)
      end

      return servers
    end

    local servers = list_servers()

    ---------------------------------------------------------------------------
    -- LOAD EACH SERVER MODULE
    ---------------------------------------------------------------------------
    for _, server in ipairs(servers) do
      require("doc.plugins.lsp.servers." .. server)(capabilities, util, coerce_path, safe_git_root, or_dirname)
    end
  end,
}
