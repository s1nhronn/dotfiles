#!/bin/sh

log() {
    printf '[%s] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >&2
}

paused=""

log INFO "DND watcher started"

while true; do
    if hyprctl activewindow -j 2>/dev/null \
        | jq -e '.fullscreen == 2' >/dev/null; then
        new="true"
    else
        new="false"
    fi

    if [ "$new" != "$paused" ]; then
        dunstctl set-paused "$new"

        if [ "$new" = "true" ]; then
            log INFO "Fullscreen detected → DND enabled"
        else
            log INFO "Fullscreen ended → DND disabled"
        fi

        paused="$new"
    fi

    sleep 1
done
