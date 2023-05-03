#!/usr/bin/env sh

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
  [8-9][0-9]|100) 
    ICON=""
    ICON_COLOR=0xffa6da95
    ;;
  [6-7][0-9])
    ICON=""
    ICON_COLOR=0xffd7da95
    ;;
  [3-5][0-9]) 
    ICON=""
    ICON_COLOR=0xffdac295
    ;;
  [1-2][0-9]) 
    ICON=""
    ICON_COLOR=0xffdaa295
    ;;
  [0-9])
    ICON=""
    ICON_COLOR=0xffda9595
    ;;
esac

if [[ $CHARGING != "" ]]; then
  ICON="󱐋"
  ICON_COLOR=0xffeed49f
fi

sketchybar --set $NAME icon=$ICON label="${PERCENTAGE}%" icon.color=${ICON_COLOR}
