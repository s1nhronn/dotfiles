#!/usr/bin/env sh
set -eu

# Показываем в меню только содержимое без ID
choice="$(cliphist list | cut -f2- | fuzzel --dmenu --prompt='Clipboard> ')" || exit 0
[ -n "$choice" ] || exit 0

# Находим ID по точному совпадению строки и декодируем
id="$(cliphist list | awk -F'\t' -v c="$choice" '$2==c {print $1; exit}')" || exit 0
[ -n "${id:-}" ] || exit 0

cliphist decode "$id" | wl-copy
