-- reload waybar
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/waybar-reload"))

-- reload hyprland
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Exit Hyprland
hl.bind("SUPER + SHIFT + ESCAPE", hl.dsp.exit())

-- Terminal
hl.bind("SUPER + Return", hl.dsp.exec_cmd(Terminal))

-- Kill focused app
hl.bind("SUPER + Q", hl.dsp.window.close())

-- Screenshot region
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

-- File manager
hl.bind("SUPER + E", hl.dsp.exec_cmd(FileManager))

-- Toggle floating
hl.bind("SUPER + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))

-- Fullscreen
hl.bind("SUPER + F", hl.dsp.window.fullscreen())

-- App launcher
hl.bind("SUPER + D", hl.dsp.exec_cmd(Menu))

-- Change wallpaper
hl.bind("SUPER + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/setwal"))

-- Notifications center
hl.bind("SUPER + A", hl.dsp.exec_cmd("swaync-client -t"))

-- Performance mode
hl.bind("SUPER + P", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/performance-toggle.sh"))

-- Zen browser
hl.bind("SUPER + Z", hl.dsp.exec_cmd("zen-browser"))

-- Toggle wifi
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("nmcli radio wifi toggle"))

-- Powermenu
hl.bind("SUPER + Escape", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/powermenu"))

-- Readest
hl.bind("SUPER + R", hl.dsp.exec_cmd("readest"))

-- Helium browser
hl.bind("SUPER + B", hl.dsp.exec_cmd("helium-browser"))

-- OBS Start/Stop
hl.bind( "SUPER + F10", hl.dsp.send_shortcut({ mods = "CTRL", key = "S", window = "class:^(com\\.obsproject\\.Studio)$" }))

-- Workspaces switching
for i = 1, 9 do
	hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
end

hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))

for i = 1, 9 do
	hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- swapping capslock and esc
-- hl.config({ input = { kb_options = "caps:swapescape", },
-- })

-- move and resize windows with mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- focus windows
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))

-- move windows
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

-- workspace navigation
hl.bind("SUPER + CTRL + H", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ workspace = "e+1" }))

-- Laptop multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { repeating = true })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { repeating = true })
