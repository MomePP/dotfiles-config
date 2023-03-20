#!/usr/bin/env sh

# The wifi_change event supplies a $INFO variable in which the current SSID
# is passed to the script.

if [[ -z "$INFO" ]]; then
    ICON="󰤫"
else
    ICON="󰤨"
fi

WIFI=${INFO:-"Not Connected"}

sketchybar --set $NAME label="${WIFI}" icon="${ICON}"
