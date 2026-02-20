require("doc.core")
require("doc.lazy")

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        -- 1. Explicitly close any sidebar that managed to open
        vim.cmd("Neotree close")
        -- 2. Identify the ghost [No Name] buffer and delete it
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if
            vim.api.nvim_buf_is_loaded(buf)
            and vim.api.nvim_buf_get_name(buf) == ""
            and vim.bo[buf].filetype ~= "alpha"
          then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
        -- 3. Force Alpha to start in the remaining clean window
        vim.cmd("Alpha")
      end)
    end
  end,
})

pcall(require, "highlight_overrides")
