#!/bin/sh

get_layout() {
  layout="$(hyprctl -j devices 2>/dev/null \
    | jq -r '.keyboards[] | select(.main == true) | .active_keymap' 2>/dev/null)"

  # fallback — первая клавиатура
  if [ -z "$layout" ] || [ "$layout" = "null" ]; then
    layout="$(hyprctl -j devices 2>/dev/null \
      | jq -r '.keyboards[0].active_keymap' 2>/dev/null)"
  fi

  case "$layout" in
    *Russian*|*ru*)  echo "RU" ;;
    *English*|*US*|*us*) echo "EN" ;;
    ""|null)        echo "--" ;;
    *)              echo "$layout" ;;
  esac
}

# бесконечный цикл вывода значения
while :; do
  get_layout
  sleep 0.2   # опрашиваем 5 раз в секунду; можно увеличить/уменьшить
done
