-- Catppuccin Mocha palette (canonical)
local C = {
  rosewater = "#f5e0dc",
  flamingo = "#f2cdcd",
  pink = "#f5c2e7",
  mauve = "#cba6f7",
  red = "#f38ba8",
  maroon = "#eba0ac",
  peach = "#fab387",
  yellow = "#f9e2af",
  green = "#a6e3a1",
  teal = "#94e2d5",
  sky = "#89dceb",
  sapphire = "#74c7ec",
  blue = "#89b4fa",
  lavender = "#b4befe",
  text = "#cdd6f4",
  subtext1 = "#bac2de",
  subtext0 = "#a6adc8",
  overlay2 = "#9399b2",
  overlay1 = "#7f849c",
  overlay0 = "#6c7086",
  surface2 = "#585b70",
  surface1 = "#45475a",
  surface0 = "#313244",
  base = "#1e1e2e",
  mantle = "#181825",
  crust = "#11111b",
}

local function set(name, opts)
  vim.api.nvim_set_hl(0, name, opts or {})
end

local function link(a, b)
  -- Force links to persist even if theme sets them
  vim.api.nvim_set_hl(0, a, { link = b, default = false })
end

local function apply_yaml_ansible()
  ---------------------------------------------------------------------------
  -- YAML (vimscript syntax)
  ---------------------------------------------------------------------------
  set("yamlPlainScalar", { fg = C.green }) -- values: green
  set("yamlString", { fg = C.green })
  set("yamlInteger", { fg = C.peach })
  set("yamlBoolean", { fg = C.peach })
  set("yamlKey", { fg = C.mauve, bold = true }) -- keys: mauve
  set("yamlBlockMappingKey", { fg = C.mauve, bold = true })
  set("yamlFlowIndicator", { fg = C.sky }) -- ':', '-', '?', etc.
  set("yamlAnchor", { fg = C.teal, italic = true })
  set("yamlAlias", { fg = C.teal, italic = true })

  ---------------------------------------------------------------------------
  -- Ansible (pearofducks/ansible-vim)
  -- Use :syn list /ansible/ to see what's present in your buffer; these are common:
  ---------------------------------------------------------------------------
  set("ansibleTheKey", { fg = C.mauve, bold = true })
  set("ansibleKey", { fg = C.mauve, bold = true })
  set("ansibleModule", { fg = C.yellow, bold = true }) -- module names
  set("ansibleTask", { fg = C.blue, bold = true }) -- 'tasks', 'name', etc.
  set("ansibleName", { fg = C.blue, italic = true }) -- task names
  set("ansibleBoolean", { fg = C.peach })
  set("ansibleAttribute", { fg = C.sapphire }) -- when, changed_when, etc.
  set("ansibleExtraKeywords", { fg = C.mauve, italic = true })

  ---------------------------------------------------------------------------
  -- Common Tree-sitter / LSP semantic tokens (for themes that mute them)
  ---------------------------------------------------------------------------
  set("@string", { fg = C.green })
  set("@number", { fg = C.peach })
  set("@boolean", { fg = C.peach })
  set("@operator", { fg = C.sky })
  set("@keyword", { fg = C.mauve, italic = true })
  set("@type", { fg = C.yellow })
  set("@type.builtin", { fg = C.yellow, italic = true })
  set("@constant", { fg = C.peach })
  set("@constant.builtin", { fg = C.peach, italic = true })
  set("@function", { fg = C.blue })
  set("@function.builtin", { fg = C.blue, italic = true })
  set("@property", { fg = C.mauve }) -- YAML keys via TS/semantic tokens
  set("@field", { fg = C.teal })
  set("@variable", { fg = C.text }) -- keep legible, but distinct if you wish

  -- If your theme still overrides some, force link to canonical groups:
  -- link("@property", "Keyword")
  -- link("@field",    "Type")
  -- link("@variable", "Identifier")
end

local function apply_all()
  apply_yaml_ansible()
end

-- Re-apply on colorscheme changes, YAML/Ansible buffers, and when LSP attaches
vim.api.nvim_create_autocmd({ "ColorScheme", "FileType", "LspAttach" }, {
  pattern = { "*", "yaml", "yaml.ansible", "ansible" },
  callback = apply_all,
})

-- Optional: If semantic tokens flatten colors for YAML, you can disable them just for YAML:
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "yaml", "yaml.ansible" },
--   callback = function()
--     vim.lsp.handlers["textDocument/semanticTokens/full"] = function() end
--     apply_all()
--   end,
-- })

-- Apply once on startup
apply_all()
