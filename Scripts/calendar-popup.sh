#!/usr/bin/env bash
set -euo pipefail

if ! command -v yad >/dev/null 2>&1; then
    printf 'Cannot open the calendar popup: yad is not installed.\n' >&2
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Calendar unavailable" "Install yad to use the Waybar calendar popup."
    fi
    exit 127
fi

exec yad \
    --calendar \
    --show-weeks \
    --day="$(date +%-d)" \
    --month="$(date +%-m)" \
    --year="$(date +%Y)" \
    --date-format="%A, %B %-d, %Y" \
    --title="Calendar" \
    --width=360 \
    --height=340 \
    --center \
    --undecorated \
    --fixed \
    --close-on-unfocus \
    --on-top \
    --skip-taskbar
