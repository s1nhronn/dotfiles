#!/usr/bin/env bash
# Простой cava-визуализатор для waybar.
# Ждём немного после старта, потом запускаем cava.
# По одному процессу на каждый бар.

# чуть подождать после старта сессии, чтобы успели подняться PipeWire/Pulse и звук
sleep 5

# убеждаемся, что cava есть
if ! command -v cava >/dev/null 2>&1; then
  exit 0
fi

# 0..7 → ▁▂▃▄▅▆▇█
bar="▁▂▃▄▅▆▇█"
dict="s/;//g"
bar_length=${#bar}
for ((i = 0; i < bar_length; i++)); do
  dict+=";s/$i/${bar:$i:1}/g"
done

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
config_file="$(mktemp "$RUNTIME_DIR/waybar-cava.XXXXXX.conf")"

cleanup() {
  rm -f "$config_file"
}
trap cleanup EXIT INT TERM

cat >"$config_file" <<EOF
[general]
framerate = 30
bars = 10

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# запускаем cava и переводим цифры 0..7 в символы полосок
cava -p "$config_file" 2>/dev/null | sed -u "$dict"
