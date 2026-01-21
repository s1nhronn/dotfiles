#!/usr/bin/env bash
set -euo pipefail

# Полный список cliphist (с ID)
list="$(cliphist list || true)"
[ -n "$list" ] || exit 0

# Показываем список без ведущего ID (цифр слева), но выбираем по индексу
if fuzzel --help 2>&1 | grep -q -- '--index'; then
  idx="$(
    printf '%s\n' "$list" \
      | sed -E 's/^[0-9]+\s+//' \
      | fuzzel --dmenu --index --prompt 'Clipboard> '
  )" || exit 0
  [ -n "${idx:-}" ] || exit 0

  # fuzzel --index возвращает индекс строки (обычно 0-based)
  line="$(printf '%s\n' "$list" | sed -n "$((idx + 1))p")"
else
  # Фолбэк если в твоём fuzzel нет --index (в этом режиме цифры не скрыть корректно)
  line="$(printf '%s\n' "$list" | fuzzel --dmenu --prompt 'Clipboard> ')" || exit 0
  [ -n "$line" ] || exit 0
fi

# Декодируем выбранный элемент и кладём в буфер
printf '%s' "$line" | cliphist decode | wl-copy

# Дать фокусу вернуться в активное окно, затем вставить из буфера
sleep 0.08
wtype -M ctrl v -m ctrl
