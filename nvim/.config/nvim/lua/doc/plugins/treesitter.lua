return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- Ensure you are tracking the new branch
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    -- New version moved incremental selection to a separate community plugin
    -- to keep the core lean. You can add it here if you want that feature back:
    { "MeanderingProgrammer/treesitter-modules.nvim" },
  },
  config = function()
    -- 1. Import the NEW singular config module
    local ts_config = require("nvim-treesitter.config")

    -- 2. Configure basic features
    ts_config.setup({
      highlight = { enable = true },
      indent = { enable = true },
      -- 'ensure_installed' is still supported in the setup table on main
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

    -- 3. Configure autotag (needs manual setup on the main branch)
    require("nvim-ts-autotag").setup()

    -- 4. NEW Incremental Selection (Native Neovim Way)
    -- If you don't use the 'treesitter-modules' plugin above,
    -- use these native mappings for similar behavior:
    vim.keymap.set("n", "<C-space>", function()
      require("nvim-treesitter.incremental_selection").init_selection()
    end)
    vim.keymap.set("x", "<C-space>", function()
      require("nvim-treesitter.incremental_selection").node_incremental()
    end)
    vim.keymap.set("x", "<bs>", function()
      require("nvim-treesitter.incremental_selection").node_decremental()
    end)
  end,
}
