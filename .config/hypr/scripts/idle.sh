#!/bin/sh

swayidle -w \
  timeout 900 '~/.config/hypr/scripts/lock.sh' \
  timeout 960 'hyprctl dispatch dpms off' \
  resume 'hyprctl dispatch dpms on' \
  before-sleep '~/.config/hypr/scripts/lock.sh'
