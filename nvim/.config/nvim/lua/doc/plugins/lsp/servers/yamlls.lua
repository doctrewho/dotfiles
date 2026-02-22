return function(capabilities, util, coerce_path, safe_git_root, or_dirname)
  vim.lsp.config("yamlls", {
    autostart = true,
    capabilities = capabilities,

    -- Only attach to plain YAML, not yaml.ansible
    filetypes = { "yaml" },

    root_dir = function(fname)
      fname = coerce_path(fname)
      return util.root_pattern(".git")(fname) or safe_git_root(fname) or or_dirname(fname)
    end,

    settings = {
      yaml = {
        keyOrdering = false,
        schemas = {}, -- avoid conflicts with ansiblels
      },
    },
  })

  vim.lsp.enable("yamlls")
end
