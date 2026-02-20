return {
  "pearofducks/ansible-vim",
  lazy = false, -- fully load plugin at startup (syntax, indent, ftplugin)
  init = function()
    -- Optional QoL toggles
    vim.g.ansible_unindent_after_newline = 1
    vim.g.ansible_attribute_highlight = "ob" -- attributes & booleans
    vim.g.ansible_name_highlight = 1 -- highlight task names
    vim.g.ansible_extra_keywords_highlight = 1 -- e.g., changed_when, loop, etc.
  end,
}
