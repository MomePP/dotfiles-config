#!/usr/bin/env sh

case "$SENDER" in
  "mouse.clicked") 
    if [ $MODIFIER = "shift" ]; then
      open "https://www.gitlab.com/"
    else
      open "https://www.github.com/"
    fi
esac

