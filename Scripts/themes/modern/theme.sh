#!/usr/bin/env bash
set -euo pipefail

settings="$HOME/.config/1f2l"
mkdir -p "$settings"

printf '%s\n' "modern" > "$settings/dock-theme"
"$HOME/.config/1f2l-dotfiles/Scripts/nwg-dock-launch.sh" &

printf '%s\n' '@import "themes/modern/style.css";' > "$HOME/.config/swaync/style.css"
swaync-client -rs

printf '%s\n' 'rofi' > "$settings/launcher"
printf '%s\n' 'modern' > "$settings/walker-theme"
printf '%s\n' 'border-2' > "$settings/hypr-window-style"
hyprctl reload
printf '%s\n' '* { border-width: 2px; }' > "$settings/rofi-border.rasi"

printf '%s\n' ":: Theme set to Modern"
