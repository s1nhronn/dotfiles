#!/usr/bin/env sh
set -eu

# NVIDIA
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1 | awk '{print $1"%"}'
  exit 0
fi

# AMD (через sysfs: загрузка GPU в процентах, если доступно)
# Обычно: /sys/class/drm/card*/device/gpu_busy_percent
p="$(find /sys/class/drm -maxdepth 3 -type f -name gpu_busy_percent 2>/dev/null | head -n1 || true)"
if [ -n "${p:-}" ] && [ -r "$p" ]; then
  cat "$p" | awk '{print $1"%"}'
  exit 0
fi

# Intel/другое: неизвестно
echo "N/A"
