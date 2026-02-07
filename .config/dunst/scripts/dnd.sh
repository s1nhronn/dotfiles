#!/bin/sh

log() {
    printf '[%s] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >&2
}

paused=""
pactl_ok="unknown" # lazy check cache

log INFO "DND watcher started"

# Проверка — есть ли активные source-outputs, которые выглядят как захват экрана.
is_screen_sharing() {
    # Проверим, доступен ли pactl
    if [ "$pactl_ok" = "unknown" ]; then
        if command -v pactl >/dev/null 2>&1; then
            pactl_ok="yes"
        else
            pactl_ok="no"
        fi
    fi

    if [ "$pactl_ok" = "no" ]; then
        return 1
    fi

    # Получаем блоки source-outputs и ищем подозрительные поля.
    # Ищем media.name/application.name/application.process.binary/media.class с ключевыми словами.
    if pactl list source-outputs 2>/dev/null | \
        grep -E -i 'media.name|application.name|application.process.binary|media.class' | \
        grep -E -i 'screen|capture|sharing|pipewire|chrome|chromium|firefox|discord|obs|zoom|teams|slack|electron' >/dev/null; then
        return 0
    fi

    return 1
}

# Вспомог: вернуть список приложений, которые сейчас захватывают (для логов)
sharing_apps_list() {
    if [ "$pactl_ok" = "no" ]; then
        return
    fi
    pactl list source-outputs 2>/dev/null \
        | awk -F' = ' '/application.name/ {gsub(/"/,"",$2); apps[$2]++} END {sep=""; for (a in apps) { printf "%s%s", sep, a; sep="," } }'
}

while true; do
    if hyprctl activewindow -j 2>/dev/null \
        | jq -e '.fullscreen == 2' >/dev/null 2>&1; then
        fs="true"
    else
        fs="false"
    fi

    # screen sharing
    if is_screen_sharing; then
        sharing="true"
    else
        sharing="false"
    fi

    if [ "$fs" = "true" ] || [ "$sharing" = "true" ]; then
        new="true"
    else
        new="false"
    fi

    if [ "$new" != "$paused" ]; then
        dunstctl set-paused "$new"

        if [ "$new" = "true" ]; then
            if [ "$fs" = "true" ] && [ "$sharing" = "true" ]; then
                apps="$(sharing_apps_list)"
                if [ -n "$apps" ]; then
                    log INFO "Fullscreen or screen-sharing detected (fullscreen + sharing: $apps) → DND enabled"
                else
                    log INFO "Fullscreen or screen-sharing detected → DND enabled"
                fi
            elif [ "$fs" = "true" ]; then
                log INFO "Fullscreen detected → DND enabled"
            else
                apps="$(sharing_apps_list)"
                if [ -n "$apps" ]; then
                    log INFO "Screen-sharing detected (apps: $apps) → DND enabled"
                else
                    log INFO "Screen-sharing detected → DND enabled"
                fi
            fi
        else
            log INFO "Fullscreen and screen-sharing ended → DND disabled"
        fi

        paused="$new"
    fi

    sleep 1
done
