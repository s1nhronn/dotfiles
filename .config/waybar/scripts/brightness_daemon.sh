#!/bin/sh
# Лёгкий демон: каждые 0.2 с читает кэш яркости и пишет в waybar

CACHE="$HOME/.cache/brightness_ddc"

# Если проц при убийстве waybar шлёт SIGPIPE — выходим тихо
trap "exit 0" PIPE

get_cached() {
  if [ -r "$CACHE" ]; then
    cur=$(cat "$CACHE" 2>/dev/null)
  fi
  [ -z "${cur-}" ] && cur=50
  echo "$cur"
}

while :; do
  cur=$(get_cached)
  printf "%s%%\n" "$cur"
  sleep 0.2
done
