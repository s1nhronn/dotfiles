#!/bin/sh
# Меняет яркость через ddcutil и обновляет кэш сразу (для быстрого UI)

DISPLAYS="1 2"           # номера мониторов из `ddcutil detect`
STEP=20                  # шаг изменения
CACHE="$HOME/.cache/brightness_ddc"

read_from_ddc() {
  total=0
  count=0

  for d in $DISPLAYS; do
    val=$(ddcutil -d "$d" getvcp 10 2>/dev/null \
      | awk -F'=' '/current value/ {gsub(/,.*$/, "", $2); gsub(/ /, "", $2); print $2}')
    [ -n "$val" ] || continue
    total=$((total + val))
    count=$((count + 1))
  done

  [ "$count" -gt 0 ] || echo 50
  [ "$count" -gt 0 ] && echo $((total / count))
}

get_current() {
  if [ -r "$CACHE" ]; then
    cur=$(cat "$CACHE" 2>/dev/null)
  fi

  if [ -z "${cur-}" ]; then
    cur=$(read_from_ddc)
    echo "$cur" >"$CACHE"
  fi

  echo "$cur"
}

set_brightness() {
  new="$1"

  [ "$new" -lt 0 ] && new=0
  [ "$new" -gt 100 ] && new=100

  # СНАЧАЛА обновляем кэш, чтобы индикатор waybar увидел новое значение
  echo "$new" >"$CACHE"

  # Потом уже отправляем команду мониторaм (это может быть медленно)
  for d in $DISPLAYS; do
    ddcutil -d "$d" setvcp 10 "$new" >/dev/null 2>&1
  done
}

case "${1-}" in
  up)
    cur=$(get_current)
    new=$((cur + STEP))
    set_brightness "$new"
    ;;
  down)
    cur=$(get_current)
    new=$((cur - STEP))
    set_brightness "$new"
    ;;
  *)
    # без аргумента ничего не делаем
    :
    ;;
esac
