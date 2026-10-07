for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "HDMI-A-1",
        persistent = true,
        default = (i == 1)
    })
end

for i = 6, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "eDP-1",
        persistent = true,
        default = (i == 6)
    })
end

hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@240",
	position = "0x0",
	scale = "auto",
	vrr = 2,
})

hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@144",
	position = "1920x0",
	scale = 1,
})
