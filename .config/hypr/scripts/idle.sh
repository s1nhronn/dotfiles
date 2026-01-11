#!/bin/sh

swayidle -w \
  timeout 900 'swaylock -f -c 000000' \
  timeout 960 'hyprctl dispatch dpms off' \
  resume 'hyprctl dispatch dpms on' \
  before-sleep 'swaylock -f -c 000000'
