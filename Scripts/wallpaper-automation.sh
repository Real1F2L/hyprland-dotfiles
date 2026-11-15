#!/usr/bin/env bash
set -euo pipefail

home="${HOME:?HOME is not set}"
cache="$home/.cache/1f2l-dotfiles"
pid_file="$cache/wallpaper-rotation.pid"
log_file="$cache/wallpaper-rotation.log"
wallpaper_dir="$home/.config/1f2l-dotfiles/Wallpapers"
interval_file="$home/.config/1f2l/wallpaper-automation"
interval=$(tr -d '[:space:]' < "$interval_file")

if [[ ! "$interval" =~ ^[1-9][0-9]*$ ]]; then
    printf 'Invalid wallpaper rotation interval in %s: %s\n' "$interval_file" "$interval" >&2
    exit 1
fi

process_start() {
    awk '{print $22}' "/proc/$1/stat" 2>/dev/null
}

rotation_running() {
    local pid stored_start current_start
    [[ -s "$pid_file" ]] || return 1
    read -r pid stored_start < "$pid_file"
    [[ "$pid" =~ ^[0-9]+$ && "$stored_start" =~ ^[0-9]+$ ]] || return 1
    current_start=$(process_start "$pid")
    [[ -n "$current_start" && "$current_start" == "$stored_start" ]]
}

run_rotation() {
    while true; do
        "$home/.config/1f2l-dotfiles/Scripts/wallpaper.sh" --random "$wallpaper_dir"
        sleep "$interval"
    done
}

case "${1:-toggle}" in
    --run)
        run_rotation
        ;;
    --start|--toggle|toggle)
        mkdir -p "$cache"
        if rotation_running; then
            if [[ "${1:-toggle}" == "--start" ]]; then
                exit 0
            fi
            read -r pid _ < "$pid_file"
            kill "$pid"
            rm -- "$pid_file"
            printf 'Wallpaper rotation stopped.\n'
            exit 0
        fi

        rm -f -- "$pid_file"
        nohup "$0" --run >> "$log_file" 2>&1 &
        pid=$!
        for _ in {1..20}; do
            start=$(process_start "$pid")
            [[ -n "$start" ]] && break
            sleep 0.05
        done
        if [[ -z "${start:-}" ]]; then
            printf 'Could not start wallpaper rotation loop (pid %s).\n' "$pid" >&2
            exit 1
        fi
        printf '%s %s\n' "$pid" "$start" > "$pid_file"
        printf 'Wallpaper rotation started; interval %ss.\n' "$interval"
        ;;
    --stop)
        if rotation_running; then
            read -r pid _ < "$pid_file"
            kill "$pid"
        fi
        rm -f -- "$pid_file"
        ;;
    *)
        printf 'Usage: %s [--start|--stop|--toggle]\n' "$0" >&2
        exit 2
        ;;
esac
