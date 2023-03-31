#!/usr/bin/env sh

# echo $INFO

ICON_PADDING_RIGHT=6

case $INFO in
  "kitty")
    ICON_PADDING_RIGHT=8
    ICON=
    ;;
  "Calendar")
    ICON=
    ;;
  "Discord")
    ICON=󰙯
    ;;
  "FaceTime")
    ICON_PADDING_RIGHT=11
    ICON=
    ;;
  "Finder")
    ICON=
    ;;
  "Microsoft Edge")
    ICON=󰇩
    ;;
  "Microsoft Teams")
    ICON=󰊻
    ;;
  "Microsoft Word")
    ICON=󱎒
    ;;
  "Microsoft Excel")
    ICON=󱎏
    ;;
  "Microsoft PowerPoint")
    ICON=󱎐
    ;;
  "Notion")
    ICON_PADDING_RIGHT=9
    ICON=
    ;;
  "Fork")
    ICON_PADDING_RIGHT=8
    ICON=
    ;;
  "Basecamp 3")
    ICON=
    ;;
  "Slack")
    ICON_PADDING_RIGHT=7
    ICON=󰒱
    ;;
  "Spotify")
    ICON_PADDING_RIGHT=5
    ICON=
    ;;
  "Arc")
    ICON_PADDING_RIGHT=7
    ICON=󰾔
    ;;
  *)
    ICON_PADDING_RIGHT=4
    ICON=󱟲
    ;;
esac

sketchybar --set $NAME icon=$ICON icon.padding_right=$ICON_PADDING_RIGHT
sketchybar --set $NAME.name label=" $INFO"
