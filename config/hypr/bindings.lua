-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Toggle between US and US International (dead keys) keyboard layouts.
o.bind("CTRL + SHIFT + K", "Toggle keyboard layout", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- Unbind default SUPER+SHIFT+S (was: Google Maps) to avoid conflict with screenshot
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")

-- Unbind default SUPER+SHIFT+M (was: Music/Spotify) to reassign to Google Maps
-- Match by window class (not the generic "Google Maps" title text), since a
-- title-based match can accidentally hit any other window whose title happens
-- to contain that phrase (e.g. a terminal title).
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "Google Maps", o.launch_webapp_sole("chrome-maps.google.com__-Default", "https://maps.google.com/"))
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
