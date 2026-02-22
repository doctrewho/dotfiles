return function(capabilities, util, coerce_path, safe_git_root, or_dirname)
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
    root_dir = function(fname)
      return safe_git_root(fname) or or_dirname(fname)
    end,
  })

  vim.lsp.enable("lua_ls")
end
