#!/bin/sh
# Waybar DND indicator script
# Emits JSON lines for waybar (used with "tail": true).
# Click handler will run "dunstctl set-paused toggle" (см. конфиг ниже).

# Настраиваемые иконки (подбери любую из твоего Nerd Font)
ICON_ON="󰂛"   # зачёркнутый колокольчик (DND ON)
ICON_OFF="󰂚"  # обычный колокольчик (DND OFF)
# Класс/текст для JSON — можно изменить под свои иконки/язык
TEXT_ON="${ICON_ON}"
TEXT_OFF="${ICON_OFF}"

prev=""

# Проверяем наличие dunstctl
if ! command -v dunstctl >/dev/null 2>&1; then
  echo "{\"text\":\"${ICON_OFF}\", \"alt\":\"no-dunstctl\", \"class\":\"missing\"}"
  # fallback: просто обновляем раз в 5s и выход (waybar покажет fallback)
  while sleep 5; do :; done
fi

# Бесконечный loop — waybar читает stdout (tail: true)
while true; do
  # dunstctl is-paused обычно печатает true/false (на некоторых версиях — "paused")
  cur="$(dunstctl is-paused 2>/dev/null || echo "false")"

  # нормализуем возможные значения
  case "$cur" in
    "true"|"TRUE"|"1"|"paused"|"Paused") cur="true" ;;
    *) cur="false" ;;
  esac

  if [ "$cur" != "$prev" ]; then
    if [ "$cur" = "true" ]; then
      echo "{\"text\":\"${TEXT_ON}\", \"alt\":\"DND on\", \"class\":\"on\"}"
    else
      echo "{\"text\":\"${TEXT_OFF}\", \"alt\":\"DND off\", \"class\":\"off\"}"
    fi
    prev="$cur"
  fi

  sleep 1
done
