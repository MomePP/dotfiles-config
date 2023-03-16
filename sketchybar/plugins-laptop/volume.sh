#!/usr/bin/env sh

VOLUME=$INFO

case $VOLUME in
  [6-9][0-9]|100)
    ICON="墳"
    ICON_PADDING_RIGHT=5
  ;;
  [3-5][0-9])
    ICON="奔"
    ICON_PADDING_RIGHT=8
  ;;
  [1-2][0-9]) 
    ICON=""
    ICON_PADDING_RIGHT=11
  ;;
  [1-9])
    ICON=""
    ICON_PADDING_RIGHT=18
  ;;
  *) 
    ICON="婢"
    ICON_PADDING_RIGHT=12
esac

sketchybar --set $NAME icon="$ICON" icon.padding_right=$ICON_PADDING_RIGHT label="$VOLUME%"
