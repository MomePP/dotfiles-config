#!/bin/sh

cur_msteams_wid=$(yabai -m query --windows --window | jq -r "if .app == \"Microsoft Teams\" and .title == \"Microsoft Teams Notification\" then .id else empty end")

if [ -n "$cur_msteams_wid" ]; then
    next_window_id=$(yabai -m query --windows --space | jq -r "map(select(.id != $cur_msteams_wid)) | first | .id // empty")
    if [ -n "$next_window_id" ]; then
        yabai -m window $next_window_id --focus;
    fi
fi
