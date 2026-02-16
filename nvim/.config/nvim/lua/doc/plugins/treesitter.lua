return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- Treesitter should not be lazy-loaded
  build = ":TSUpdate", -- keep parsers in sync with the plugin

  dependencies = {
    "windwp/nvim-ts-autotag",
  },

  config = function()
    -- ✅ NEW API on the `main` branch:
    --    require the top-level module and call `.setup()`
    local TS = require("nvim-treesitter")

    TS.setup({
      highlight = { enable = true },
      indent = { enable = true },

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
        -- Add what you preview/edit to improve Telescope previews:
        -- "typescript", "tsx", "html", "css", "markdown", "markdown_inline"
      },

      -- ✅ Use real keycodes (no HTML entities)
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

    require("nvim-ts-autotag").setup()
  end,
}
