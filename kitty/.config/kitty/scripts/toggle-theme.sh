#!/usr/bin/env bash

THEME_FILE="$HOME/.config/kitty/theme.conf"
THEME_DIR="$HOME/.config/kitty/colors"

themes=(
"rose-pine.conf"
"rose-pine-moon.conf"
"rose-pine-dawn.conf"
)

current=$(grep include "$THEME_FILE" | cut -d'/' -f2)

next="${themes[0]}"

for i in "${!themes[@]}"; do
    if [[ "${themes[$i]}" == "$current" ]]; then
        next="${themes[$(( (i+1) % ${#themes[@]} ))]}"
        break
    fi
done

echo "include colors/$next" > "$THEME_FILE"

kitty @ set-colors --all --configured "$THEME_DIR/$next"

notify-send "Kitty Theme" "$next"