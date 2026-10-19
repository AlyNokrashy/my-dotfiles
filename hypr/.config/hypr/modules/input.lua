hl.config({
	input = {
		kb_layout = "us,ara",
		kb_options = "grp:alt_shift_toggle",

		repeat_rate = 50,
		repeat_delay = 300,

		follow_mouse = true,

		-- Range is -1.0 to 1.0 | 0 means no modification to sensitivity.
		sensitivity = -0.3,

		touchpad = {
			natural_scroll = true,
		},
	},

	cursor = {
		no_hardware_cursors = true,
	},
})
