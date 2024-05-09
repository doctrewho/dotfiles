return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local keymap = vim.keymap -- for consiseness

    keymap.set("n", "<leader>ee", "<cmd>Neotree toggle<CR>", { desc = "Neotree Toggle" })
    keymap.set("n", "<leader>nb", "<cmd>Neotree buffers reveal float<CR>", { desc = "Neotree buffer show" })
    keymap.set("n", "<leader>ng", "<cmd>Neotree float git_status<CR>", { desc = "Neotree git status window" })

    require("neo-tree").setup({
      close_if_last_window = true,
      enable_git_status = true,
      git_status = {
        symbols = {
          -- Change type
          added = "",
          modified = "",
          deleted = "",
          renamed = "",
          -- Status type
          untracked = "",
          ignored = "󰿠",
          unstaged = "",
          staged = "",
          conflict = "",
        },
      },
      window = {
        position = "left",
        width = 60,
        mappings = {
          ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
        },
      },
      symlink_target = {
        enabled = true,
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = {
            ".git",
          },
        },
      },
    })
  end,
}
