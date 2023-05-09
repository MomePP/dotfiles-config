#!/usr/bin/env sh

source "$CONFIG_DIR/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
  [8-9][0-9]|100) 
    ICON="􀛨"
    ICON_COLOR=$BATTERY_LEVEL5_COLOR
    ;;
  [6-7][0-9])
    ICON="􀺸"
    ICON_COLOR=$BATTERY_LEVEL4_COLOR
    ;;
  [3-5][0-9]) 
    ICON="􀺶"
    ICON_COLOR=$BATTERY_LEVEL3_COLOR
    ;;
  [1-2][0-9]) 
    ICON="􀛩"
    ICON_COLOR=$BATTERY_LEVEL2_COLOR
    ;;
  [0-9])
    ICON="􀛪"
    ICON_COLOR=$BATTERY_LEVEL1_COLOR
    ;;
esac

if [[ $CHARGING != "" ]]; then
  ICON="􀢋"
  ICON_COLOR=$BATTERY_CHARGING_COLOR
fi

sketchybar --set $NAME icon=$ICON label="${PERCENTAGE}%" icon.color=${ICON_COLOR}
