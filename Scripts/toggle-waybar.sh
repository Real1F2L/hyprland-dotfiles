#!/usr/bin/env bash
#  _____                 _        ____  _        _            _
# |_   _|__   __ _  __ _| | ___  / ___|| |_ __ _| |_ _   _ __| |__   __ _ _ __
#   | |/ _ \ / _` |/ _` | |/ _ \ \___ \| __/ _` | __| | | / _` | '_ \ / _` | '__|
#   | | (_) | (_| | (_| | |  __/  ___) | || (_| | |_| |_| \__,_| |_) | (_| | |
#   |_|\___/ \__, |\__, |_|\___| |____/ \__\__,_|\__|\__,_|\__,_|_.__/ \__,_|_|
#            |___/ |___/
#
# Toggle the active statusbar. Read its selection from
# ~/.config/1f2l/statusbar and toggles the matching bar.

settings_file="$HOME/.config/1f2l/statusbar"

# Default to waybar if no setting file is present.
statusbar="waybar"
if [ -f "$settings_file" ]; then
    statusbar=$(tr -d '[:space:]' < "$settings_file")
fi

case "$statusbar" in
    quickshell)
        qs ipc call statusbar toggle
        ;;
    waybar)
        "$HOME/.config/1f2l-dotfiles/Scripts/waybar-toggle.sh"
        ;;
    *)
        echo "Unknown statusbar '$statusbar' in $settings_file" >&2
        exit 1
        ;;
esac
