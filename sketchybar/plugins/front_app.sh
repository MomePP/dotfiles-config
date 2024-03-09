#!/usr/bin/env sh

window_state() {
  source "$CONFIG_DIR/colors.sh"

  APP_NAME=$(sketchybar --query front_app | jq -r '.label.value | split(" [") | first')
  WINDOW=$(yabai -m query --windows --window)
  STACK_INDEX=$(echo "$WINDOW" | jq '.["stack-index"]')
  COLOR=$WHITE

  if [ "$(echo "$WINDOW" | jq '.["is-floating"]')" = "true" ]; then
    COLOR=$MAGENTA
  elif [ "$(echo "$WINDOW" | jq '.["has-fullscreen-zoom"]')" = "true" ]; then
    COLOR=$GREEN
  elif [ "$(echo "$WINDOW" | jq '.["has-parent-zoom"]')" = "true" ]; then
    COLOR=$BLUE
  elif [[ $STACK_INDEX -gt 0 ]]; then
    LAST_STACK_INDEX=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
    APP_NAME="$(printf "%s [%s/%s]" "$APP_NAME" "$STACK_INDEX" "$LAST_STACK_INDEX")"
  fi

  if [ ! -z "$APP_NAME" ]; then 
    sketchybar --set $NAME label="$APP_NAME"
  fi
  sketchybar --set $NAME label.color=$COLOR --animate sin 10
}

mouse_clicked() {
  yabai -m window --toggle float
  window_state
}

update_app_icon() {
  sketchybar --set $NAME label="$INFO" icon.background.image="app.$INFO"
}

case "$SENDER" in
  "front_app_switched") update_app_icon
  ;;
  "mouse.clicked") mouse_clicked
  ;;
  "window_focus") window_state 
  ;;
esac

