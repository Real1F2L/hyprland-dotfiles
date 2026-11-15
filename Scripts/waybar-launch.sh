#!/usr/bin/env bash
set -euo pipefail

runtime_dir="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR is not set}"
exec 200>"$runtime_dir/1f2l-waybar-launch.lock"
flock -n 200 || exit 0

if [[ -f "$HOME/.config/1f2l/waybar-disabled" ]]; then
    while IFS= read -r pid; do
        kill "$pid" 2>/dev/null || true
    done < <(pgrep -u "$UID" -x waybar || true)
    exit 0
fi

while IFS= read -r pid; do
    kill "$pid" 2>/dev/null || true
done < <(pgrep -u "$UID" -x waybar || true)

sleep 0.25
signature=$(hyprctl instances -j | jq -er '.[0].instance')
HYPRLAND_INSTANCE_SIGNATURE="$signature" \
    waybar --config "$HOME/.config/waybar/config" --style "$HOME/.config/waybar/style.css" 200>&- &
