----------------------- dwindle layout ---------------------------

hl.config({
	dwindle = {
		preserve_split = true,
	},
})

-- ----------------------- scrolling layout ---------------------------
hl.config({
	scrolling = {
		column_width = 0.5,
		direction = "right",
		fullscreen_on_one_column = true,
		focus_fit_method = 1,
		explicit_column_widths = "0.5, 1.0",
		follow_focus = true,
	}
})

----------------------- master layout ---------------------------

hl.config({
	master = {
		new_status = "master",
	},
})
