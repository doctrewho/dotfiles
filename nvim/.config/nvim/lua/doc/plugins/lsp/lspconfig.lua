return {
  "neovim/nvim-lspconfig",
  event = { "VeryLazy", "BufReadPre", "BufNewFile" },

  dependencies = {
    "williamboman/mason.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },

  config = function()
    local mason = require("mason")
    mason.setup()

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

    local signs = {
      Error = "",
      Warn = "",
      Hint = "",
      Info = "",
    }

    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

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

    vim.lsp._config = vim.lsp._config or {}

    local servers_dir = vim.fn.stdpath("config") .. "/lua/doc/plugins/lsp/servers"
    local template_file = servers_dir .. "/new_server.template"

    local function list_server_files()
      local paths = vim.fn.globpath(servers_dir, "*.lua", false, true)
      local names = {}
      for _, path in ipairs(paths) do
        table.insert(names, vim.fn.fnamemodify(path, ":t:r"))
      end
      return names
    end

    vim.api.nvim_create_user_command("LspList", function()
      local servers = list_server_files()
      print("Configured LSP servers:")
      for _, s in ipairs(servers) do
        print("  " .. s)
      end
    end, {})

    vim.api.nvim_create_user_command("LspEdit", function(opts)
      local server = vim.trim(opts.args)
      if server == "" then
        print("No server name provided")
        return
      end
      local path = servers_dir .. "/" .. server .. ".lua"
      if vim.fn.filereadable(path) == 1 then
        vim.cmd("edit " .. path)
      else
        print("Server config not found: " .. server)
      end
    end, {
      nargs = 1,
      complete = function()
        return list_server_files()
      end,
    })

    vim.api.nvim_create_user_command("LspNew", function(opts)
      local server = vim.trim(opts.args)
      if server == "" then
        print("No server name provided")
        return
      end

      local target = servers_dir .. "/" .. server .. ".lua"

      if vim.fn.filereadable(target) == 1 then
        print("Config already exists: " .. server)
        return
      end

      if vim.fn.filereadable(template_file) ~= 1 then
        print("Missing template file: new_server.template")
        return
      end

      vim.fn.copy(template_file, target)
      print("Created new server config: " .. server)
    end, {
      nargs = 1,
    })

    vim.api.nvim_create_user_command("LspRemove", function(opts)
      local server = vim.trim(opts.args)
      if server == "" then
        print("No server name provided")
        return
      end

      local path = servers_dir .. "/" .. server .. ".lua"
      if vim.fn.filereadable(path) ~= 1 then
        print("Server config not found: " .. server)
        return
      end

      vim.fn.delete(path)
      print("Removed server config: " .. server)
    end, {
      nargs = 1,
      complete = function()
        return list_server_files()
      end,
    })

    vim.api.nvim_create_user_command("LspValidateServers", function()
      local servers = list_server_files()
      print("Validating server configs…")

      for _, s in ipairs(servers) do
        local ok, err = pcall(function()
          require("doc.plugins.lsp.servers." .. s)(capabilities, util, coerce_path, safe_git_root, or_dirname)
        end)
        if not ok then
          print("Invalid config for " .. s .. ": " .. err)
        end
      end

      print("Validation complete.")
    end, {})

    --------------------------------------------------------------------
    -- LspDoctor (floating window + quickfix list + q to close)
    --------------------------------------------------------------------
    vim.api.nvim_create_user_command("LspDoctor", function()
      local servers = list_server_files()
      local qf = {}

      local lines = {}
      table.insert(lines, "LSP Doctor Report")
      table.insert(lines, "=================")
      table.insert(lines, "")

      for _, s in ipairs(servers) do
        local path = servers_dir .. "/" .. s .. ".lua"

        if vim.fn.filereadable(path) ~= 1 then
          local msg = "Missing file: " .. s
          table.insert(lines, "❌ " .. msg)
          table.insert(qf, {
            filename = path,
            lnum = 1,
            col = 1,
            text = msg,
            type = "E",
          })
        else
          local ok, err = pcall(function()
            require("doc.plugins.lsp.servers." .. s)(capabilities, util, coerce_path, safe_git_root, or_dirname)
          end)

          if ok then
            table.insert(lines, "✔ OK: " .. s)
          else
            local msg = "Error in " .. s .. ": " .. err
            table.insert(lines, "❌ " .. msg)
            table.insert(qf, {
              filename = path,
              lnum = 1,
              col = 1,
              text = msg,
              type = "E",
            })
          end
        end
      end

      table.insert(lines, "")
      table.insert(lines, "LSP Doctor complete.")

      --------------------------------------------------------------------
      -- Floating window
      --------------------------------------------------------------------
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      local width = math.floor(vim.o.columns * 0.6)
      local height = math.floor(vim.o.lines * 0.6)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
      })

      -- ⭐ Add q-to-close behavior
      vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(win, true)
      end, { buffer = buf, silent = true })

      --------------------------------------------------------------------
      -- Quickfix list
      --------------------------------------------------------------------
      vim.fn.setqflist({}, " ", {
        title = "LSP Doctor",
        items = qf,
      })

      print("LSP Doctor complete.")
    end, {})

    --------------------------------------------------------------------

    local servers = list_server_files()

    for _, server in ipairs(servers) do
      require("doc.plugins.lsp.servers." .. server)(capabilities, util, coerce_path, safe_git_root, or_dirname)
    end
  end,
}
