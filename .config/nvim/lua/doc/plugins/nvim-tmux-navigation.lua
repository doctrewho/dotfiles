return {
  "alexghergh/nvim-tmux-navigation",
  config = function()
    local keymap = vim.keymap
    require("nvim-tmux-navigation").setup({})
    keymap.set("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { desc = "TMUX Navigate Left" })
    keymap.set("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { desc = "TMUX Navigate Down" })
    keymap.set("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { desc = "TMUX Navigate Up" })
    keymap.set("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", { desc = "TMUX Navigate Right" })
  end,
}
