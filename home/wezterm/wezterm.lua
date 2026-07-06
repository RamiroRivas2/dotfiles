-- WezTerm config
-- Windows translation of home/.config/wezterm/wezterm.lua from kunchenguid/dotfiles.
-- bootstrap.ps1 points the WEZTERM_CONFIG_FILE env var at this file, so edit
-- HERE and WezTerm reloads automatically (Ctrl+Shift+R forces a reload).

local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
-- Hack Nerd Font is what the video uses; JetBrainsMono is the fallback you
-- already had installed, in case the Hack install ever goes missing.
config.font = wezterm.font_with_fallback({ "Hack Nerd Font", "JetBrainsMono Nerd Font" })
-- his Mac uses 15.0; macOS points render bigger than Windows points,
-- so ~12 looks the same here. Bump it if it feels small.
config.font_size = 12.0
config.window_background_opacity = 0.8
-- Windows version of macos_window_background_blur
config.win32_system_backdrop = "Acrylic"
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- start in PowerShell 7 (your daily shell). On his Mac this is implicit (zsh).
config.default_prog = { "pwsh.exe", "-NoLogo" }

-- your old setup launched straight into WSL Ubuntu instead.
-- to go back to that, comment out default_prog above and uncomment:
-- config.default_domain = "WSL:Ubuntu"

return config
