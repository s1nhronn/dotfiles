#!/usr/bin/env bash
set -euo pipefail

sel="$(cliphist list | fuzzel --dmenu --prompt 'Clipboard> ')" || exit 0
[ -n "$sel" ] || exit 0

printf '%s' "$sel" | cliphist decode | wl-copy
