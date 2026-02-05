return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "MeanderingProgrammer/treesitter-modules.nvim",
  },
  config = function()
    -- USE 'config' (singular), NOT 'configs'
    local ts_config = require("nvim-treesitter.config")

    ts_config.setup({
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "json",
        "yaml",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "vimdoc",
      },
    })

    -- Restores the missing 'incremental_selection' logic
    require("treesitter-modules").setup({
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })

    -- Setup autotag separately
    require("nvim-ts-autotag").setup()
  end,
}
