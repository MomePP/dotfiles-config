#!/bin/sh

# INFO: update spaces number to matched with display count
DESIRED_SPACES_PER_DISPLAY=4
CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces | @sh')"

DISPLAY_INDEX=1
DELTA=0
while read -r line
do
  LAST_SPACE="$(echo "${line##* }")"
  LAST_SPACE=$(($LAST_SPACE+$DELTA))
  EXISTING_SPACE_COUNT="$(echo "$line" | wc -w)"
  MISSING_SPACES=$(($DESIRED_SPACES_PER_DISPLAY - $EXISTING_SPACE_COUNT))
  if [ "$MISSING_SPACES" -gt 0 ]; then
    for i in $(seq 1 $MISSING_SPACES)
    do
      yabai -m space --create "$DISPLAY_INDEX"
      LAST_SPACE=$(($LAST_SPACE+1))
    done
  elif [ "$MISSING_SPACES" -lt 0 ]; then
    for i in $(seq 1 $((-$MISSING_SPACES)))
    do
      yabai -m space --destroy "$LAST_SPACE"
      LAST_SPACE=$(($LAST_SPACE-1))
    done
  fi
  DELTA=$(($DELTA+$MISSING_SPACES))
  DISPLAY_INDEX=$(($DISPLAY_INDEX+1))
done <<< "$CURRENT_SPACES"

# INFO: update kitty terminal font size
DISPLAY_COUNT="$(yabai -m query --displays | jq -r '. | length')"

if [ "$DISPLAY_COUNT" -gt 1 ]; then
  kitty @ --to unix:/tmp/mykitty set-font-size 13.5
else
  kitty @ --to unix:/tmp/mykitty set-font-size 13.0
fi
