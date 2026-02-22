return function(capabilities, util, coerce_path, safe_git_root, or_dirname)
  local root = function(fname)
    return safe_git_root(fname) or or_dirname(fname)
  end

  require("lspconfig")[vim.fn.expand("%:t:r")].setup({
    capabilities = capabilities,
    root_dir = root,
    settings = {},
  })
end
