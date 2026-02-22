return function(capabilities, util, coerce_path, safe_git_root, or_dirname)
  local cfg = {
    name = "ansiblels",
    autostart = true,
    cmd = { "ansible-language-server", "--stdio" },
    capabilities = capabilities,
    filetypes = { "yaml", "yaml.ansible" },

    root_dir = function(fname)
      fname = coerce_path(fname)
      return util.root_pattern("ansible.cfg", ".ansible-lint")(fname) or safe_git_root(fname) or vim.loop.cwd()
    end,

    settings = {
      ansible = {
        ansible = { path = "ansible", useFullyQualifiedCollectionNames = true },
        ansibleLint = { enabled = true, path = "ansible-lint" },
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
    end,
  }

  vim.lsp.config("ansiblels", cfg)
  vim.lsp.enable("ansiblels")
end
