return {
  "nvim-telescope/telescope.nvim",

  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    { "folke/trouble.nvim", opts = {} },
  },

  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod

    local has_trouble, trouble = pcall(require, "trouble")
    local trouble_telescope = has_trouble and require("trouble.sources.telescope") or nil

    local custom_actions = transform_mod({
      open_trouble_qflist = function(_)
        if has_trouble then
          trouble.toggle("quickfix")
        end
      end,
    })

    telescope.setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = { width = 0.9, preview_width = 0.6 },
          vertical = { mirror = false },
          preview_cutoff = 120,
        },
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope and trouble_telescope.smart_open_with_trouble or nil,
          },
        },
      },
      extensions = {
        ["ui-select"] = { require("telescope.themes").get_dropdown() },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")

    local map = vim.keymap.set
    map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
    map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    map("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
    map("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    map("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
  end,
}
