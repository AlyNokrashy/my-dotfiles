#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if pgrep -x wofi >/dev/null; then
    pkill wofi
    exit
fi

selected=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f -exec basename {} \; | sort | wofi --dmenu --prompt "Select wallpaper")

[ -z "$selected" ] && exit

awww img "$WALLPAPER_DIR/$selected" \
    --transition-type center \
    --transition-step 20 \
    --transition-fps 60