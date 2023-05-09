#!/usr/bin/env sh

SOURCE=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID)

LABEL='A'
case ${SOURCE} in
    'com.apple.keylayout.ABC') LABEL='ENG' ;;
    'com.apple.keylayout.Thai') LABEL='Thai' ;;
esac

sketchybar --set $NAME label="$LABEL"
