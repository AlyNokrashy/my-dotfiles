hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix dragging issues with XWayland
hl.window_rule({
	name = "windowrule-18",
	no_focus = true,
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
})

-- zen
hl.window_rule({
	name = "zen-opacity",
	match = {
		class = "^(zen)$",
	},

	-- acitve inactive fullscreen
	opacity = "1 override 1 1 override",
})

-- helium
hl.window_rule({
	name = "helium-opacity",
	match = {
		class = "^(helium)$",
	},

	-- acitve inactive fullscreen
	opacity = "1 override 1 1 override",
})

-- chrome (helium apps)
hl.window_rule({
	name = "chrome-opacity",
	match = {
		class = "^chrome-.*-Default$",
	},

	-- acitve inactive fullscreen
	opacity = "1 override 1 1 override",
})

hl.window_rule({
	name = "mpv-opacity",
	match = {
		class = "^(mpv)$",
	},

	-- acitve inactive fullscreen
	opacity = "1 override 1 1 override",
})

hl.window_rule({
	name = "stremio-opacity",
	match = {
		class = "com.stremio.stremio",
	},

	-- acitve inactive fullscreen
	opacity = "1 override 1 1 override",
})

hl.window_rule({
	name = "float-nsxiv",
	match = {
		class = "Nsxiv",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.7)", "(monitor_h*0.7)" },
	animation = "popin 80%",
	dim_around = true,
})

-- bluetuie as floating window
hl.window_rule({
	name = "bluetui-floating",
	match = {
		class = "kitty",
		title = "bluetui-popup",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.7)", "(monitor_h*0.7)" },
	animation = "popin 80%",
	dim_around = true,
})

hl.window_rule({
	name = "wlctl-floating",
	match = {
		class = "kitty",
		title = "wlctl-popup",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.7)", "(monitor_h*0.7)" },
	animation = "popin 80%",
	dim_around = true,
})

hl.window_rule({
	name = "btop-floating",
	match = {
		class = "kitty",
		title = "btop-popup",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.7)", "(monitor_h*0.7)" },
	animation = "popin 80%",
	dim_around = true,
})

hl.window_rule({
	name = "pavucontrol-floating",
	match = {
		title = "Volume Control",
	},
	float = true,
	center = true,
	size = { "(monitor_w*0.7)", "(monitor_h*0.7)" },
	animation = "popin 80%",
	dim_around = true,
})

hl.layer_rule({
	name = "wlogout-blur",
	blur = true,
	match = {
		namespace = "logout_dialog",
	},
	animation = "fade",
})

hl.layer_rule({
	match = {
		namespace = "waybar",
	},
	blur = true,
	ignore_alpha = 0.5,
	no_anim = true,
})
