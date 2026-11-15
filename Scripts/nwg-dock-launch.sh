#!/usr/bin/env bash
#    ___           __
#   / _ \___  ____/ /__
#  / // / _ \/ __/  '_/
# /____/\___/\__/_/\_\
#

settings="$HOME/.config/1f2l"
theme="modern"
if [[ -f "$settings/dock-theme" ]]; then
    IFS= read -r theme < "$settings/dock-theme"
fi

style="$HOME/.config/nwg-dock-hyprland/themes/$theme/style.css"
if [[ ! -f "$style" ]]; then
    printf 'Dock theme stylesheet not found: %s\n' "$style" >&2
    exit 1
fi

pkill -x nwg-dock-hyprland 2>/dev/null || true
if [[ -f "$settings/dock-disabled" ]]; then
    printf '%s\n' ":: Dock disabled"
    exit 0
fi

sleep 0.5
if [[ -f "$settings/dock-autohide" ]]; then
    nwg-dock-hyprland -d -hd 60 -i 32 -w 5 -mb 10 -x -s "$style" -c "$HOME/.config/1f2l-dotfiles/Scripts/launcher.sh"
else
    nwg-dock-hyprland -i 32 -w 5 -mb 10 -x -s "$style" -c "$HOME/.config/1f2l-dotfiles/Scripts/launcher.sh"
fi