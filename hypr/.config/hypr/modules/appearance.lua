local wal = dofile(os.getenv("HOME") .. "/.cache/wal/colors-hyprland.lua")

----------------------- Animations ---------------------------

hl.config({
	animations = {
		enabled = true,
	},
})

hl.curve("smooth", {
	type = "bezier",
	points = {
		{ 0.25, 0.1 },
		{ 0.25, 1 },
	},
})

hl.curve("rubber", {
	type = "spring",
	mass = 1,
	stiffness = 70,
	dampening = 10, })

-- opening/moving tiled windows
hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 4,
	bezier = "smooth",
})

-- window pop-in animation when a new window appears
hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 4,
	bezier = "smooth",
	style = "popin 80%",
})

-- closing windows
hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 4,
	bezier = "smooth",
})

-- active window border when focus changes
hl.animation({
	leaf = "border",
	enabled = true,
	speed = 4,
	bezier = "smooth",
})

-- transparency changes (window focus change, some UI transitions)
hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 4,
	bezier = "smooth",
})

-- switching workspaces
hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 2,
	bezier = "smooth",
	style = "slidefade 20%",
})

----------------------- General ---------------------------

hl.config({
	general = {
		-- inner/outer gaps between windows
		gaps_in = 4,
		gaps_out = 7,

		border_size = 2,

		col = {
			active_border = wal.colors.color5,
			inactive_border = wal.colors.color0,
		},

		-- enables resizing windows by clicking and dragging on borders and gaps-
		resize_on_border = true,

		layout = "dwindle",
	},
})

----------------------- Window Decorations ---------------------------

hl.config({
	decoration = {
		rounding = 0,

		active_opacity = 0.85,
		inactive_opacity = 0.65,
		fullscreen_opacity = 1,

		-- window shadow
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},
		-- noctalia's blur from docs
		-- blur = {
		--     enabled = true,
		--     size = 3,
		--     passes = 2,
		--     vibrancy = 0.1696,
		--   },

		-- Transparent window blur
		blur = {
			enabled = true,
			size = 6,
			passes = 2,
			ignore_opacity = true,

			noise = 0.02,
			xray = false,
			contrast = 1.5,
			brightness = 0.8,
		},
	},
})

----------------------- dwindle layout ---------------------------

hl.config({
	dwindle = {
		preserve_split = true,
	},
})

----------------------- master layout ---------------------------

hl.config({
	master = {
		new_status = "master",
	},
})

----------------------- misc ---------------------------

hl.config({
	misc = {
		force_default_wallpaper = false,
		disable_hyprland_logo = true,
	},
})
