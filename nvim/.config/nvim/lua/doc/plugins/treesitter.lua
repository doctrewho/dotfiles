return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",

  dependencies = {
    "windwp/nvim-ts-autotag",
    -- "nvim-treesitter/nvim-treesitter-textobjects", -- optional
  },

  config = function()
    local ok_config, configs = pcall(require, "nvim-treesitter.config")
    if not ok_config then
      vim.notify("[treesitter] nvim-treesitter.config not found. Run :Lazy sync", vim.log.levels.WARN)
      return
    end

    configs.setup({
      ensure_installed = {
        "bash",
        "dockerfile",
        "gitignore",
        "json",
        "lua",
        "query",
        "vim",
        "vimdoc",
        "yaml",
        -- add as needed:
        -- "python", "markdown", "markdown_inline", "html", "css", "tsx", "typescript"
      },

      -- CRITICAL: allow Vimscript YAML/Ansible syntax to run with TS
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "yaml" },
      },

      indent = { enable = true }, -- toggle off if YAML indent feels off

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-Space>",
          node_incremental = "<C-Space>",
          scope_incremental = false,
          node_decremental = "<BS>",
        },
      },
    })

    -- Optional, safe setup
    local ok_autotag, autotag = pcall(require, "nvim-ts-autotag")
    if ok_autotag then
      autotag.setup()
    end
  end,
}
