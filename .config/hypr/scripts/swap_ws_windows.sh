#!/bin/sh
# Поменять местами все окна между активными workspace-ами на DP-1 и DP-2

set -e

MON1="DP-1"
MON2="DP-2"

monitors_json="$(hyprctl -j monitors 2>/dev/null)"

ws1="$(printf '%s\n' "$monitors_json" | jq ".[] | select(.name==\"$MON1\") | .activeWorkspace.id")"
ws2="$(printf '%s\n' "$monitors_json" | jq ".[] | select(.name==\"$MON2\") | .activeWorkspace.id")"

# если что-то не нашли — выходим тихо
[ -z "$ws1" ] || [ -z "$ws2" ] && exit 0

clients_json="$(hyprctl -j clients 2>/dev/null)"

# сначала запомним адреса окон на каждом workspace
addrs_ws1="$(printf '%s\n' "$clients_json" | jq -r ".[] | select(.workspace.id==$ws1) | .address")"
addrs_ws2="$(printf '%s\n' "$clients_json" | jq -r ".[] | select(.workspace.id==$ws2) | .address")"

# переносим окна с ws1 на ws2
for addr in $addrs_ws1; do
  hyprctl dispatch movetoworkspace "$ws2,address:$addr"
done

# переносим окна с ws2 на ws1
for addr in $addrs_ws2; do
  hyprctl dispatch movetoworkspace "$ws1,address:$addr"
done
