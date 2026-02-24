return function(capabilities, util, coerce_path, safe_git_root, or_dirname)
  local server_name = "ansiblels"

  vim.lsp._config = vim.lsp._config or {}

  local function compute_root(fname)
    fname = coerce_path(fname)
    local root = util.root_pattern("ansible.cfg", ".ansible-lint", "requirements.yml", "roles", "playbooks")(fname)
    return root or safe_git_root(fname) or or_dirname(fname)
  end

  local config = {
    name = server_name,
    cmd = { "ansible-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.ansible" },

    -- IMPORTANT: store a STRING, not a function
    root_dir = compute_root(vim.api.nvim_buf_get_name(0)),

    capabilities = capabilities,

    settings = {
      ansible = {
        ansible = {
          useFullyQualifiedCollectionNames = true,
        },
        python = {
          interpreterPath = "python",
        },
      },
    },
  }

  vim.lsp._config[server_name] = config

  vim.api.nvim_create_autocmd("FileType", {
    pattern = config.filetypes,
    callback = function(args)
      local bufnr = args.buf
      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = server_name })
      if #clients == 0 then
        -- Recompute root_dir for this buffer
        local fname = vim.api.nvim_buf_get_name(bufnr)
        config.root_dir = compute_root(fname)

        vim.lsp.start(vim.tbl_extend("force", config, { bufnr = bufnr }))
      end
    end,
  })
end
