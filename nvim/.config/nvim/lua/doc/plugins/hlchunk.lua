return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        style = {
          { fg = "#a6e3a1" },
          { fg = "#f38ba8" },
        },
      },
    })

    local default_conf = {
      priority = 15,
      style = {
        { fg = "#806d9c" },
        { fg = "#c21f30" },
      },
      use_treesitter = true,
      chars = {
        horizontal_line = "─",
        vertical_line = "│",
        left_top = "╭",
        left_bottom = "╰",
        right_arrow = ">",
      },
      textobject = "",
      max_file_size = 1024 * 1024,
      error_sign = true,
      -- animation related
      duration = 200,
      delay = 300,
    }
  end,
}
