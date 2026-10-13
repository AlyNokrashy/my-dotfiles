dofile(os.getenv("HOME") .. "/.config/hypr/modules/variables.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/modules/env.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/modules/monitor.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/modules/input.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/modules/autostart.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/modules/rules.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/modules/appearance.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/modules/keybinds.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/modules/layout.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/modules/plugins.lua")




-- For Noctalia Color templates
require("noctalia").apply_theme()
