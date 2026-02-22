return function(capabilities, util, coerce_path, safe_git_root, or_dirname)
  vim.lsp.config("pyright", {
    autostart = true,
    capabilities = capabilities,
    root_dir = function(fname)
      fname = coerce_path(fname)
      return util.root_pattern("pyproject.toml", "setup.py", "requirements.txt", ".git")(fname)
        or safe_git_root(fname)
        or or_dirname(fname)
    end,
  })

  vim.lsp.enable("pyright")
end
