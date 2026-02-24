return function(capabilities, util, coerce_path, safe_git_root, or_dirname)
  local server_name = "pyright"

  local function compute_root(fname)
    fname = coerce_path(fname)
    return util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt")(fname)
      or safe_git_root(fname)
      or or_dirname(fname)
  end

  local config = {
    name = server_name,
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },

    root_dir = compute_root(vim.api.nvim_buf_get_name(0)),

    capabilities = capabilities,
  }

  vim.lsp._config[server_name] = config

  vim.api.nvim_create_autocmd("FileType", {
    pattern = config.filetypes,
    callback = function(args)
      local bufnr = args.buf
      local fname = vim.api.nvim_buf_get_name(bufnr)

      config.root_dir = compute_root(fname)

      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = server_name })
      if #clients == 0 then
        vim.lsp.start(vim.tbl_extend("force", config, { bufnr = bufnr }))
      end
    end,
  })
end
