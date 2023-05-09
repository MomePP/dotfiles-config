#!/usr/bin/env sh

window_state() {
  source "$CONFIG_DIR/colors.sh"

  WINDOW=$(yabai -m query --windows --window)
  STACK_INDEX=$(echo "$WINDOW" | jq '.["stack-index"]')

  COLOR=$GREY
  ICON=􀧍

  if [ "$(echo "$WINDOW" | jq '.["is-floating"]')" = "true" ]; then
    ICON=􀢌
    COLOR=$MAGENTA
  elif [ "$(echo "$WINDOW" | jq '.["has-fullscreen-zoom"]')" = "true" ]; then
    ICON=􀏜
    COLOR=$GREEN
  elif [ "$(echo "$WINDOW" | jq '.["has-parent-zoom"]')" = "true" ]; then
    ICON=􀥃
    COLOR=$BLUE
  elif [[ $STACK_INDEX -gt 0 ]]; then
    LAST_STACK_INDEX=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
    ICON=􀏭
    LABEL="$(printf "[%s/%s]" "$STACK_INDEX" "$LAST_STACK_INDEX")"
    COLOR=$RED
  fi

  args=(--animate sin 10 --set $NAME icon.color=$COLOR)

  [ -z "$LABEL" ] && args+=(label.width=0) \
                  || args+=(label="$LABEL" label.width=40)

  [ -z "$ICON" ] && args+=(icon.width=0) \
                 || args+=(icon="$ICON" icon.width=34)

  sketchybar -m "${args[@]}"
}

mouse_clicked() {
  yabai -m window --toggle float
  window_state
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "forced") exit 0
  ;;
  "window_focus") window_state 
  ;;
esac
