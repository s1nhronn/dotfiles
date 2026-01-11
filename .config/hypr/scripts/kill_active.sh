#!/bin/sh

pid="$(hyprctl activewindow -j | jq '.pid')"

if [ -n "$pid" ] && [ "$pid" != "null" ]; then
  kill -9 "$pid"
fi
