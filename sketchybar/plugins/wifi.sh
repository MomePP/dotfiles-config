#!/usr/bin/env sh

# The wifi_change event supplies a $INFO variable in which the current SSID
# is passed to the script.
if [ "$SENDER" = "wifi_change" ]; then
    INFO="$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}' | xargs networksetup -getairportnetwork | sed "s/Current Wi-Fi Network: //")"
    if [[ -z "$INFO" ]] || [[ -z "${INFO##You are not*}" ]]; then
        ICON="󰤫"
        WIFI="Not Connected"
    else
        ICON="󰤨"
        WIFI=$(echo $INFO | tr -d '\t')
    fi
    sketchybar --set $NAME label="${WIFI}" icon="${ICON}"
fi
