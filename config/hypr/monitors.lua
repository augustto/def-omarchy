-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Alienware m16 R1 built-in panel (left).
hl.monitor({ output = "eDP-2", mode = "2560x1600@240", position = "0x0", scale = 1.6 })

-- ASUS PA278CGRV, 2K 144Hz (right, primary).
hl.monitor({ output = "DP-4", mode = "2560x1440@144", position = "1600x0", scale = 1 })

-- Fallback for any other/future monitor.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

hl.config({ cursor = { default_monitor = "DP-4" } })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
