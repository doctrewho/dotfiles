return {
  "neovim/nvim-lspconfig",
  -- Load early so registrations exist before :checkhealth and before first YAML buffers
  event = { "VeryLazy", "BufReadPre", "BufNewFile" },

  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },

  config = function()
    -- 0) Mason install management
    local mason = require("mason")
    mason.setup()

    local mason_lspconfig = require("mason-lspconfig")
    mason_lspconfig.setup({
      ensure_installed = { "lua_ls", "pyright", "ansiblels", "svelte", "graphql", "emmet_ls" },
      automatic_installation = true,
    })

    -- 1) Buffer-local keymaps on attach
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

    -- 2) Diagnostic signs
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- 3) Shared capabilities
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local util = require("lspconfig.util")

    -- 4) Register servers with the Neovim 0.11+ API and enable them

    -- Lua
    vim.lsp.config("lua_ls", {
      autostart = true,
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          completion = { callSnippet = "Replace" },
          workspace = { checkThirdParty = false },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    -- Pyright
    vim.lsp.config("pyright", {
      autostart = true,
      capabilities = capabilities,
      root_dir = util.root_pattern("pyproject.toml", "setup.py", "requirements.txt", ".git"),
    })
    vim.lsp.enable("pyright")

    -- Svelte
    vim.lsp.config("svelte", {
      autostart = true,
      capabilities = capabilities,
      on_attach = function(client, _)
        vim.api.nvim_create_autocmd("BufWritePost", {
          pattern = { "*.js", "*.ts" },
          callback = function(ctx)
            client.notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.file) })
          end,
        })
      end,
    })
    vim.lsp.enable("svelte")

    -- GraphQL
    vim.lsp.config("graphql", {
      autostart = true,
      capabilities = capabilities,
      filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
      root_dir = util.root_pattern(".graphqlrc", ".graphqlrc.*", "graphql.config.*", ".git"),
    })
    vim.lsp.enable("graphql")

    -- Emmet
    vim.lsp.config("emmet_ls", {
      autostart = true,
      capabilities = capabilities,
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    })
    vim.lsp.enable("emmet_ls")

    -- Ansible (more forgiving root_dir)
    local ansible_cfg = {
      name = "ansiblels", -- explicit name helps when starting manually
      autostart = true,
      cmd = { "ansible-language-server", "--stdio" },
      capabilities = capabilities,
      filetypes = { "yaml", "yaml.ansible" }, -- or just { "yaml" } if you want to avoid health noise
      root_dir = function(fname)
        return util.root_pattern("ansible.cfg", ".ansible-lint")(fname)
          or util.find_git_ancestor(fname)
          or vim.loop.cwd()
      end,
      settings = {
        ansible = {
          ansible = { path = "ansible", useFullyQualifiedCollectionNames = true },
          ansibleLint = { enabled = true, path = "ansible-lint" }, -- set enabled=false temporarily if needed
          executionEnvironment = { enabled = false },
          python = { interpreterPath = "python" },
          completion = {
            provideRedirectModules = true,
            provideModuleOptionAliases = true,
          },
        },
      },
      on_attach = function(_, bufnr)
        vim.b.ansiblels_attached = true
        -- Uncomment if you want a visual confirmation:
        vim.notify("ansiblels attached to buffer " .. bufnr, vim.log.levels.INFO)
      end,
    }
    vim.lsp.config("ansiblels", ansible_cfg)
    vim.lsp.enable("ansiblels")

    -- 5) Defensive: if autostart didn’t fire, start ansiblels on FileType (idempotent)
    local util = require("lspconfig.util")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "yaml", "yaml.ansible" },
      callback = function(args)
        local bufnr = args.buf

        -- Skip non-normal buffers and health buffers
        local bt, ft = vim.bo[bufnr].buftype, vim.bo[bufnr].filetype
        if bt ~= "" and bt ~= "acwrite" then
          return
        end
        if ft == "checkhealth" then
          return
        end

        -- Already attached? do nothing
        if #vim.lsp.get_clients({ bufnr = bufnr, name = "ansiblels" }) > 0 then
          return
        end

        -- Build a fresh, minimal config to avoid sharing closures/tables
        local root = util.root_pattern("ansible.cfg", ".ansible-lint")(vim.api.nvim_buf_get_name(bufnr))
          or util.find_git_ancestor(vim.api.nvim_buf_get_name(bufnr))
          or vim.loop.cwd()

        vim.lsp.start({
          name = "ansiblels",
          cmd = { "ansible-language-server", "--stdio" },
          autostart = true,
          capabilities = capabilities,
          root_dir = root,
          filetypes = { "yaml" }, -- simplest. Use only yaml to avoid health “unknown filetype” noise
          settings = {
            ansible = {
              ansible = { path = "ansible", useFullyQualifiedCollectionNames = true },
              ansibleLint = { enabled = true, path = "ansible-lint" }, -- set false to test
              executionEnvironment = { enabled = false },
              python = { interpreterPath = "python" },
              completion = {
                provideRedirectModules = true,
                provideModuleOptionAliases = true,
              },
            },
          },
        }, { bufnr = bufnr })
      end,
    })
  end,
}
