return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ee", "<cmd>Neotree toggle<CR>", { desc = "Neotree Open" })
    keymap.set("n", "<leader>nb", "<cmd>Neotree buffers reveal float<CR>", { desc = "Neotree buffer reveal" })
    keymap.set("n", "<leader>ng", "<cmd>Neotree float git_status<CR>", { desc = "Neotree git status" })

    require("neo-tree").setup({
      close_if_last_window = false,
      enable_git_status = true,
      git_status = {
        symbols = {
          -- Change type
          added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
          modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
          deleted = "", -- this can only be used in the git_status source
          renamed = "󰁕", -- this can only be used in the git_status source
          -- Status type
          untracked = "",
          ignored = "",
          unstaged = "󰄱",
          staged = "",
          conflict = "",
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
