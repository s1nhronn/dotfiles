#!/bin/sh

dir="$HOME/Изображения/Снимки экрана"
mkdir -p "$dir"
ts="$(date +'%Y-%m-%d_%H-%M-%S')"

get_active_output() {
  hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .name'
}

case "$1" in
  # 1. Активный монитор -> буфер
  monitor_clip)
    out="$(get_active_output)"
    grim -o "$out" - | wl-copy && notify-send "Screenshot" "Active monitor -> clipboard"
    ;;

  # 2. Все мониторы -> буфер
  all_clip)
    grim - | wl-copy && notify-send "Screenshot" "All monitors -> clipboard"
    ;;

  # 3. Область -> буфер
  region_clip)
    grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot" "Region -> clipboard"
    ;;

  # 4. Активный монитор -> файл
  monitor_file)
    out="$(get_active_output)"
    file="$dir/monitor_${ts}.png"
    grim -o "$out" "$file" && notify-send "Screenshot" "Saved $file"
    ;;

  # 5. Все мониторы -> файл
  all_file)
    file="$dir/all_${ts}.png"
    grim "$file" && notify-send "Screenshot" "Saved $file"
    ;;

  # 6. Область -> файл
  region_file)
    file="$dir/region_${ts}.png"
    grim -g "$(slurp)" "$file" && notify-send "Screenshot" "Saved $file"
    ;;
esac
