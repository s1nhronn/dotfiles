#!/usr/bin/env bash
set -euo pipefail

FILE="pkgs/hyprland.txt"

usage() {
  echo "Usage: $0 <package> [--keep]" >&2
  echo "" >&2
  echo "Default: uninstall package (yay -Rns) AND remove it from $FILE." >&2
  echo "  --keep  Only remove from $FILE, do not uninstall from system." >&2
  exit 1
}

(( $# >= 1 && $# <= 2 )) || usage
pkg="$1"
keep=0

if (( $# == 2 )); then
  [[ "$2" == "--keep" ]] || usage
  keep=1
fi

# 1) Uninstall from system (default behaviour)
if (( keep == 0 )); then
  command -v yay >/dev/null 2>&1 || { echo "Error: yay not found" >&2; exit 2; }
  yay -Rns "$pkg"
fi

# 2) Remove from list file (exact match)
if [[ -f "$FILE" ]]; then
  tmp="$(mktemp)"
  awk -v pkg="$pkg" '$0 == pkg { next } { print }' "$FILE" > "$tmp"
  mv "$tmp" "$FILE"

  # Keep the file tidy: collapse many blank lines
  tmp="$(mktemp)"
  awk '
  BEGIN{ blank=0 }
  {
    if ($0 ~ /^[[:space:]]*$/) {
      blank++
      if (blank <= 2) print
      next
    }
    blank=0
    print
  }
  ' "$FILE" > "$tmp"
  mv "$tmp" "$FILE"

  echo "Removed from $FILE: $pkg"
else
  echo "Warning: $FILE not found, removed from system only: $pkg" >&2
fi
