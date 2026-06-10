#!/bin/bash

STATE_FILE="/tmp/hypr_perf_mode"

if [ -f "$STATE_FILE" ]; then
    # Disable performance mode
    hyprctl keyword animations:enabled true
    hyprctl keyword decoration:blur:enabled true
    rm "$STATE_FILE"
    notify-send "Hyprland" "Performance mode OFF"
else
    # Enable performance mode
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:blur:enabled false
    touch "$STATE_FILE"
    notify-send "Hyprland" "Performance mode ON"
fi
