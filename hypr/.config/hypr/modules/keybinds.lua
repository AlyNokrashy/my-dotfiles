local mainMod = "SUPER"
local nocMod = "ALT"
local ipc = "noctalia msg "

------------ noctalia binds ------------------

-- Core binds
hl.bind(mainMod .. "+D", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. "+S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(nocMod .. "+comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mainMod .. "+W", hl.dsp.exec_cmd(ipc .. "panel-toggle wallpaper"))
hl.bind(mainMod .. "+SHIFT+W", hl.dsp.exec_cmd(ipc .. "panel-toggle noctalia/wallhaven:browser"))
hl.bind(mainMod .. "+SHIFT+Q", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
hl.bind(mainMod .. "+SHIFT+S", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind(nocMod .. "+period", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
hl.bind(mainMod .. "+A", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center notifications"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher hold"))

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"))


-- Double tap for windows key
local tapTimer = nil
local function on_double_tap(mods, key, callback, timeout, opts)
	timeout = timeout or 300
	local bindString
	if mods then
		bindString = mods .. " + " .. key
	else
		bindString = key
	end
	hl.bind(bindString, function()
		if tapTimer then
			tapTimer = nil
			callback()
		else
			tapTimer = hl.timer(function()
				tapTimer = nil
			end, { timeout = timeout, type = "oneshot" })
		end
	end, opts)
end


-- reload waybar
hl.bind(mainMod .. "+ SHIFT + B", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/waybar-reload"))

-- reload hyprland
hl.bind(mainMod .. "+ SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Exit Hyprland
hl.bind(mainMod .. "+ SHIFT + ESCAPE", hl.dsp.exit())

-- Terminal
hl.bind(mainMod .. "+ Return", hl.dsp.exec_cmd(Terminal))

-- Kill focused app
hl.bind(mainMod .. "+ Q", hl.dsp.window.close())

-- -- Screenshot region
-- hl.bind(mainMod .. "+ SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

-- File manager
hl.bind(mainMod .. "+ E", hl.dsp.exec_cmd(FileManager))

-- Toggle floating
hl.bind(mainMod .. "+ SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))

-- Fullscreen
hl.bind(mainMod .. "+ F", hl.dsp.window.fullscreen())

-- App launcher
hl.bind(mainMod .. "+ D", hl.dsp.exec_cmd(Menu))

-- -- Change wallpaper
-- hl.bind(mainMod .. "+ W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/setwal"))

-- -- Notifications center
-- hl.bind(mainMod .. "+ A", hl.dsp.exec_cmd("swaync-client -t"))

-- Performance mode
hl.bind(mainMod .. "+ P", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/performance-toggle.sh"))

-- Zen browser
hl.bind(mainMod .. "+ Z", hl.dsp.exec_cmd("zen-browser"))

-- Toggle wifi
hl.bind(mainMod .. "+ SHIFT + W", hl.dsp.exec_cmd("nmcli radio wifi toggle"))

-- -- Powermenu
-- hl.bind(mainMod .. "+ Escape", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/powermenu"))

-- Readest
hl.bind(mainMod .. "+ R", hl.dsp.exec_cmd("readest"))

-- Helium browser
hl.bind(mainMod .. "+ B", hl.dsp.exec_cmd("helium-browser"))

-- OBS Start/Stop
hl.bind(
	mainMod .. "+ F10",
	hl.dsp.send_shortcut({ mods = "CTRL", key = "S", window = "class:^(com\\.obsproject\\.Studio)$" })
)

-- Workspaces switching
for i = 1, 9 do
	hl.bind(mainMod .. "+ " .. i, hl.dsp.focus({ workspace = i }))
end

hl.bind(mainMod .. "+ 0", hl.dsp.focus({ workspace = 10 }))

for i = 1, 9 do
	hl.bind(mainMod .. "+ SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. "+ SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- swapping capslock and esc
-- hl.config({ input = { kb_options = "caps:swapescape", },
-- })

-- move and resize windows with mouse
hl.bind(mainMod .. "+ mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "+ mouse:273", hl.dsp.window.resize(), { mouse = true })

-- focus windows
hl.bind(mainMod .. "+ H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. "+ L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. "+ K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. "+ J", hl.dsp.focus({ direction = "d" }))

-- move windows
hl.bind(mainMod .. "+ SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. "+ SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. "+ SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. "+ SHIFT + J", hl.dsp.window.move({ direction = "d" }))

-- workspace navigation
hl.bind(mainMod .. "+ CTRL + H", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. "+ CTRL + L", hl.dsp.focus({ workspace = "e+1" }))

-- Scrolling layout keys --
hl.bind(mainMod .. "+ period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. "+ comma", hl.dsp.layout("move -col"))
-- hl.bind(mainMod .. "+ equal", hl.dsp.layout("colresize +conf"))
on_double_tap(mainMod, "SUPER_L", function()
	hl.dispatch(hl.dsp.layout("colresize +conf"))
end, 300, { release = true })

-- scrolling overview plugin
hl.bind(mainMod .. "+g", function()
    hl.plugin.scrolloverview.overview("toggle all")
end)

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- scrolling overview plugin
hl.plugin.scrolloverview.gesture({ fingers = 3, direction = "vertical" })
hl.plugin.scrolloverview.gesture({ fingers = 4, direction = "vertical", mod = "SUPER", scale = 1.5 })
hl.plugin.scrolloverview.gesture({ fingers = 4, direction = "vertical", disable_inhibit = true })
hl.plugin.scrolloverview.gesture({ fingers = 3, direction = "vertical", action = "unset" })

-- keymaps inside the overview view
hl.define_submap("scrolloverview", function()
    hl.bind("h",   hl.plugin.scrolloverview.navigate("left"))
    hl.bind("l",  hl.plugin.scrolloverview.navigate("right"))
    hl.bind("k",     hl.plugin.scrolloverview.navigate("up"))
    hl.bind("j",   hl.plugin.scrolloverview.navigate("down"))
    hl.bind("return", hl.plugin.scrolloverview.overview("select"))
    hl.bind("escape", hl.plugin.scrolloverview.overview("off"))
    hl.bind("mouse:272", function()
        -- Select the clicked window, or just the workspace if no window was clicked, then close the overview. This is the default behaviour if submap is not defined.
        hl.plugin.scrolloverview.overview("select")
        hl.plugin.scrolloverview.window("select")
        hl.plugin.scrolloverview.overview("off")
    end, { mouse = true })
    hl.bind("mouse:274", hl.plugin.scrolloverview.window("close"), { mouse = true })
end)

-- Laptop multimedia keys
-- hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
--
-- hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
--
-- hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
--
-- hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
--
-- hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { repeating = true })
--
-- hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { repeating = true })
