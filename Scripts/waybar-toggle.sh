#!/usr/bin/env bash
set -euo pipefail

marker="$HOME/.config/1f2l/waybar-disabled"
mkdir -p "$(dirname "$marker")"
if [[ -e "$marker" ]]; then
    rm -- "$marker"
else
    : > "$marker"
fi

exec "$HOME/.config/1f2l-dotfiles/Scripts/waybar-launch.sh"
