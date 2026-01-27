#!/usr/bin/env bash
set -euo pipefail

# swaylock-effects (обычно бинарь всё равно называется swaylock)
swaylock \
  --daemonize \
  --clock \
  --indicator \
  --screenshots \
  --effect-blur 8x8 \
  --effect-vignette 0.25:0.25 \
  --ring-color 89b4faff \
  --inside-color 11111b66 \
  --key-hl-color a6e3a1ff \
  --text-color cdd6f4ff \
  --line-color 00000000 \
  --separator-color 00000000 \
  --ring-wrong-color f38ba8ff \
  --inside-wrong-color 11111b66 \
  --text-wrong-color cdd6f4ff
