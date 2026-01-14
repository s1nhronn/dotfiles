#!/bin/sh

CONFIG="$HOME/.config/cava/config-waybar"

# Маппинг уровней 0–7 в символы
level_to_char() {
  case "$1" in
    0) printf " " ;;
    1) printf "▁" ;;
    2) printf "▂" ;;
    3) printf "▃" ;;
    4) printf "▄" ;;
    5) printf "▅" ;;
    6) printf "▆" ;;
    7) printf "▇" ;;
    *) printf " " ;;
  esac
}

cava -p "$CONFIG" 2>/dev/null | while read -r line; do
  # line — строка из символов 0–7 от cava (по одному символу на бар)
  bars=""
  i=0
  len=${#line}
  while [ "$i" -lt "$len" ]; do
    c=$(printf '%s' "$line" | cut -c $((i+1)))
    # переводим символ в цифру (0–7)
    case "$c" in
      [0-7]) lvl="$c" ;;
      *) lvl=0 ;;
    esac
    bars="$bars$(level_to_char "$lvl")"
    i=$((i+1))
  done

  track=""
  if command -v playerctl >/dev/null 2>&1; then
    track=$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)
  fi

  [ -n "$track" ] && text="$bars  $track" || text="$bars"

  # экранируем кавычки для JSON
  text=${text//\"/\\\"}

  printf '{ "text": "%s" }\n' "$text"
done
