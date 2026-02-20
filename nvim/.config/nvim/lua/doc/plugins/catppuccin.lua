return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000, -- make sure it loads before other UI-affecting plugins
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      integrations = {
        treesitter = true,
        -- You can add others you use:
        -- native_lsp = { enabled = true, virtual_text = true, underlines = { errors = { "underline" }, hints = { "underline" }, warnings = { "underline" }, information = { "underline" } } },
        -- telescope = true,
        -- mason = true,
        -- lsp_trouble = true,
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
