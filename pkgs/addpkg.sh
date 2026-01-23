#!/usr/bin/env bash
set -euo pipefail

FILE="pkgs/hyprland.txt"

usage() {
  echo "Usage: $0 <package> <section 1|2|3|4>" >&2
  exit 1
}

(( $# == 2 )) || usage
pkg="$1"
sec="$2"

case "$sec" in
  1) header="# 1) Десктопные пакеты (GUI-приложения)" ;;
  2) header="# 2) Консольные пакеты (CLI-утилиты/разработка)" ;;
  3) header="# 3) Пакеты для Hyprland (компоненты окружения/сессии)" ;;
  4) header="# 4) Зависимости / базовый слой / “обвязка”" ;;
  *) usage ;;
esac

command -v yay >/dev/null 2>&1 || { echo "Error: yay not found" >&2; exit 2; }

# install
yay -S --needed "$pkg"

# ensure file exists
touch "$FILE"

# already listed?
if grep -Fxq "$pkg" "$FILE"; then
  echo "Already in $FILE: $pkg"
  exit 0
fi

# ensure header exists
if ! grep -Fxq "$header" "$FILE"; then
  # add a blank line before new header if needed
  if [[ -s "$FILE" ]]; then
    tail -n 1 "$FILE" | grep -qE '^\s*$' || echo >> "$FILE"
  fi
  printf "%s\n\n" "$header" >> "$FILE"
fi

tmp="$(mktemp)"
awk -v header="$header" -v pkg="$pkg" '
function is_header(line){ return line ~ /^# / }
function flush_block() {
  if (in_target) {
    n=0
    # collect existing package lines (ignore blanks/comments)
    for (i=1; i<=block_n; i++) {
      line=block[i]
      if (line ~ /^[[:space:]]*$/) continue
      if (is_header(line)) continue
      pkgs[++n]=line
    }
    pkgs[++n]=pkg

    # unique
    delete seen
    m=0
    for (i=1; i<=n; i++) {
      if (!(pkgs[i] in seen)) {
        seen[pkgs[i]]=1
        uniq[++m]=pkgs[i]
      }
    }

    # print header (first line in block)
    print block[1]

    # sort if gawk, else keep insertion order
    if (PROCINFO["version"] != "") {
      asort(uniq)
      for (i=1; i<=m; i++) print uniq[i]
    } else {
      for (i=1; i<=m; i++) print uniq[i]
    }
    print ""
  } else {
    for (i=1; i<=block_n; i++) print block[i]
  }

  delete pkgs; delete uniq
  block_n=0
  in_target=0
}
BEGIN{ block_n=0; in_target=0 }
{
  if (is_header($0)) {
    if (block_n>0) flush_block()
    in_target = ($0 == header)
    block[++block_n]=$0
    next
  }
  block[++block_n]=$0
}
END{ if (block_n>0) flush_block() }
' "$FILE" > "$tmp"
mv "$tmp" "$FILE"

echo "Added $pkg to section $sec"
