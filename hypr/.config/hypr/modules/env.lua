-- Nvidia
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")
hl.env("LIBVA_DRIVER_NAME", "nvidia")

-- XDG
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- hyprshot
hl.env("HYPRSHOT_DIR", "/home/aly/Pictures/Screenshots")

-- Cursor
hl.env("XCURSOR_THEME", "BreezeX-RosePineDawn-Linux")
hl.env("XCURSOR_SIZE", "24")

-- Wayland 
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("CLUTTER_BACKEND", "wayland")

-- QT 
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
