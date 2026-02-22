local function is_wsl()
  local uname = vim.loop.os_uname().release
  return uname:lower():find("microsoft") ~= nil or uname:lower():find("wsl") ~= nil
end

local win_clip = "/mnt/c/Windows/System32/clip.exe"
local win_pwsh = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

if is_wsl() then
  -- Make ALL yanks go to the Windows clipboard
  vim.opt.clipboard = "unnamedplus"

  vim.g.clipboard = {
    name = "WSL Clipboard",
    copy = {
      ["+"] = "sh -c '" .. win_clip .. "'",
      ["*"] = "sh -c '" .. win_clip .. "'",
    },
    paste = {
      ["+"] = 'sh -c "' .. win_pwsh .. " -NoProfile -Command Get-Clipboard | tr -d '\\r'\"",
      ["*"] = 'sh -c "' .. win_pwsh .. " -NoProfile -Command Get-Clipboard | tr -d '\\r'\"",
    },
    cache_enabled = 0,
  }
end
