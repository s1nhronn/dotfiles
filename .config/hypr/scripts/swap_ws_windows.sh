#!/bin/sh
# Поменять местами все окна между активными workspace-ами на DP-1 и DP-2
# с использованием временного workspace, чтобы не мешались макеты.

set -e

MON1="DP-1"
MON2="DP-2"
TMP_WS=1001  # временный workspace, вне диапазона 1–10

monitors_json="$(hyprctl -j monitors 2>/dev/null)"

ws1="$(printf '%s\n' "$monitors_json" | jq ".[] | select(.name==\"$MON1\") | .activeWorkspace.id")"
ws2="$(printf '%s\n' "$monitors_json" | jq ".[] | select(.name==\"$MON2\") | .activeWorkspace.id")"

# если что-то не нашли или активные WS одинаковые — выходим
[ -z "$ws1" ] && exit 0
[ -z "$ws2" ] && exit 0
[ "$ws1" = "$ws2" ] && exit 0

clients_json="$(hyprctl -j clients 2>/dev/null)"

# адреса окон на каждом workspace ДО перемещений
addrs_ws1="$(printf '%s\n' "$clients_json" | jq -r ".[] | select(.workspace.id==$ws1) | .address")"
addrs_ws2="$(printf '%s\n' "$clients_json" | jq -r ".[] | select(.workspace.id==$ws2) | .address")"

# 1. Переносим все окна с ws1 во временный TMP_WS
for addr in $addrs_ws1; do
  hyprctl dispatch movetoworkspace "$TMP_WS,address:$addr"
done

# 2. Переносим все окна с ws2 в ws1
for addr in $addrs_ws2; do
  hyprctl dispatch movetoworkspace "$ws1,address:$addr"
done

# 3. Переносим окна из TMP_WS (бывший ws1) в ws2
for addr in $addrs_ws1; do
  hyprctl dispatch movetoworkspace "$ws2,address:$addr"
done
