#!/usr/bin/env sh

# The wifi_change event supplies a $INFO variable in which the current SSID
# is passed to the script.
# if [ "$SENDER" = "wifi_change" ]; then
    INFO="$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F ' SSID: '  '/ SSID: / {print $2}')"
    if [[ -z "$INFO" ]]; then
        ICON="󰤫"
    else
        ICON="󰤨"
    fi
    WIFI=${INFO:-"Not Connected"}

    sketchybar --set $NAME label="${WIFI}" icon="${ICON}"
# fi
