#!/usr/bin/env sh

source "$CONFIG_DIR/colors.sh"

# Max number of characters so it fits nicely to the right of the notch
# MAY NOT WORK WITH NON-ENGLISH CHARACTERS
MAX_LENGTH=35
HALF_LENGTH=$(((MAX_LENGTH + 1) / 2))

update_track() {
  # $INFO comes in malformed or not Spotify app, line below sanitizes it
  CURRENT_APP=$(echo $INFO | jq -r .app)
  if [ $CURRENT_APP != "Spotify" ]; then
    sketchybar --set $NAME icon.color=$YELLOW
    return
  fi

  PLAYER_STATE=$(echo "$INFO" | jq -r .state)
  if [ $PLAYER_STATE = "playing" ]; then
    TRACK="$(echo "$INFO" | jq -r .title)"
    ARTIST="$(echo "$INFO" | jq -r .artist)"

    # Calculations so it fits nicely
    TRACK_LENGTH=${#TRACK}
    ARTIST_LENGTH=${#ARTIST}

    if [ $((TRACK_LENGTH + ARTIST_LENGTH)) -gt $MAX_LENGTH ]; then
      # If the total length exceeds the max
      if [ $TRACK_LENGTH -gt $HALF_LENGTH ] && [ $ARTIST_LENGTH -gt $HALF_LENGTH ]; then
        # If both the track and artist are too long, cut both at half length - 1
        # If MAX_LENGTH is odd, HALF_LENGTH is calculated with an extra space, so give it an extra char
        TRACK="${TRACK:0:$((MAX_LENGTH % 2 == 0 ? HALF_LENGTH - 2 : HALF_LENGTH - 1))}…"
        ARTIST="${ARTIST:0:$((HALF_LENGTH - 2))}…"

      elif [ $TRACK_LENGTH -gt $HALF_LENGTH ]; then
        # Else if only the track is too long, cut it by the difference of the max length and artist length
        TRACK="${TRACK:0:$((MAX_LENGTH - ARTIST_LENGTH - 1))}…"
      elif [ $ARTIST_LENGTH -gt $HALF_LENGTH ]; then
        ARTIST="${ARTIST:0:$((MAX_LENGTH - TRACK_LENGTH - 1))}…"
      fi
    fi
    sketchybar --set $NAME label="${TRACK}  ${ARTIST}" label.drawing=yes icon.color=$GREEN

  elif [ $PLAYER_STATE = "paused" ]; then
    sketchybar --set $NAME icon.color=$YELLOW
  fi
}

case "$SENDER" in
  "mouse.clicked") 
    if [ $BUTTON = "left" ]; then
      osascript -e 'tell application "Spotify" to playpause'
    else
      osascript -e 'tell application "Spotify" to next track'
    fi
    ;;
  "media_change")
    update_track
    ;;
esac
