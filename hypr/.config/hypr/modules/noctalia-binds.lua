local mainMod = "SUPER"
local ipc = "noctalia msg "

-- Core binds
hl.bind(mainMod .. "+D", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. "+S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. "+comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mainMod .. "+W", hl.dsp.exec_cmd(ipc .. "panel-toggle wallpaper"))
hl.bind(mainMod .. "+Escape", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
hl.bind(mainMod .. "+SHIFT+S", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind(mainMod .. "+period", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
hl.bind(mainMod .. "+A", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center notifications"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher hold"))

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"))

