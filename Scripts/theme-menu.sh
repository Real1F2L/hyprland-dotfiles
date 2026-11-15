#!/usr/bin/env bash
set -euo pipefail

script_dir="$(dirname "$(realpath "$0")")"
themes_dir="$script_dir/themes"
launcher_file="$HOME/.config/1f2l/launcher"
launcher="rofi"
if [[ -f "$launcher_file" ]]; then
    IFS= read -r launcher < "$launcher_file" || true
fi

if command -v walker >/dev/null 2>&1; then
    theme_options=$(find "$themes_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
else
    theme_options=$(find "$themes_dir" -mindepth 1 -maxdepth 1 -type d ! -name '*-walker' -printf '%f\n' | sort)
fi

if [[ "$launcher" == "walker" ]]; then
    selected_theme=$("$script_dir/walker-launch.sh" -d -N -H -p "Search Theme" <<< "$theme_options")
else
    selected_theme=$(rofi -dmenu -replace -config "$HOME/.config/rofi/config-themes.rasi" -i -no-show-icons -l 5 -width 30 <<< "$theme_options")
fi

if [[ -z "$selected_theme" ]]; then
    exit 0
fi

theme_script="$themes_dir/$selected_theme/theme.sh"
if [[ ! -f "$theme_script" ]]; then
    printf 'Unknown theme selection: %s\n' "$selected_theme" >&2
    exit 1
fi

source "$theme_script"
