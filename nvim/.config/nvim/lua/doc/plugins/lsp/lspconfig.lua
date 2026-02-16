return {
  "neovim/nvim-lspconfig",
  -- Load early so :checkhealth sees LSP registrations
  event = { "VeryLazy", "BufReadPre", "BufNewFile" },

  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim", -- installation only; no setup_handlers anymore
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} }, -- must init before lua_ls config
  },

  config = function()
    local mason_ok, mason = pcall(require, "mason")
    if mason_ok then
      mason.setup()
    end

    local mlsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if mlsp_ok then
      mason_lspconfig.setup({
        ensure_installed = { "lua_ls", "pyright", "ansiblels", "svelte", "graphql", "emmet_ls" },
        automatic_installation = true,
      })
    end

    pcall(require, "neodev")

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        local keymap = vim.keymap

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

    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    local util = require("lspconfig.util")

    -- Pyright
    vim.lsp.config("pyright", {
      capabilities = capabilities,
      root_dir = util.root_pattern("pyproject.toml", "setup.py", "requirements.txt", ".git"),
    })

    -- Lua (lua_ls)
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      root_dir = util.root_pattern(".luarc.json", ".luarc.jsonc", ".git"),
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          completion = { callSnippet = "Replace" },
          workspace = { checkThirdParty = false },
        },
      },
    })

    -- Svelte
    vim.lsp.config("svelte", {
      capabilities = capabilities,
      root_dir = util.root_pattern("svelte.config.js", "package.json", ".git"),
      on_attach = function(client, bufnr)
        -- Notify Svelte LS when TS/JS files change
        vim.api.nvim_create_autocmd("BufWritePost", {
          pattern = { "*.js", "*.ts" },
          callback = function(ctx)
            client.notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.file) })
          end,
        })
      end,
    })

    -- GraphQL
    vim.lsp.config("graphql", {
      capabilities = capabilities,
      filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
      root_dir = util.root_pattern(".graphqlrc", ".graphqlrc.*", "graphql.config.*", ".git"),
    })

    -- Emmet
    vim.lsp.config("emmet_ls", {
      capabilities = capabilities,
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
      root_dir = util.root_pattern(".git", "."),
    })

    -- Ansible
    vim.lsp.config("ansiblels", {
      capabilities = capabilities,
      filetypes = { "yaml", "yaml.ansible" }, -- if you don't have yaml.ansible ft, "yaml" is fine
      root_dir = util.root_pattern("ansible.cfg", ".ansible-lint", ".git", "."),
      settings = {
        ansible = {
          ansible = {
            path = "ansible",
            useFullyQualifiedCollectionNames = true,
          },
          ansibleLint = { enabled = true, path = "ansible-lint" },
          executionEnvironment = { enabled = false },
          python = { interpreterPath = "python" },
          completion = {
            provideRedirectModules = true,
            provideModuleOptionAliases = true,
          },
        },
      },
    })

    -- 8) (Optional) If you prefer explicit start instead of autostart:
    --    You can start per-filetype, but in 0.11+ autostart should work once
    --    you've registered a server with vim.lsp.config and it matches filetype/root.
    --    Example of explicit start (not required typically):
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = { "lua", "python", "svelte", "graphql", "typescriptreact", "javascriptreact", "html", "yaml" },
    --   callback = function(args)
    --     -- The server name is inferred by Neovim from the registration; explicit starts are rarely needed now.
    --     -- But if you want to force start:
    --     -- vim.lsp.start(vim.lsp.get_configs().lua_ls) -- example for Lua
    --   end,
    -- })
  end,
}
