#!/usr/bin/env bash
set -u

home="${HOME:?HOME is not set}"
support="$home/.config/1f2l-dotfiles"
scripts="$support/Scripts"
cache="$home/.cache/1f2l-dotfiles"

mkdir -p "$cache"

run_step() {
    "$@" || printf 'Startup step failed: %s\n' "$*" >&2
}

start_background() {
    "$@" &
}

run_step dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
run_step systemctl --user restart xdg-desktop-portal-hyprland.service xdg-desktop-portal.service
run_step hyprctl setcursor bibata-modern-classic 24

start_background qs
start_background qs -p "$home/.config/quickshell/overview"
start_background awww-daemon
start_background nm-applet --indicator
start_background "$scripts/waybar-launch.sh"
start_background "$scripts/nwg-dock-launch.sh"
start_background /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run_step "$scripts/listeners.sh" --startall
run_step "$scripts/gtk.sh"
start_background swaync
start_background hypridle
start_background wl-paste --watch cliphist store
run_step "$scripts/cleanup.sh"

wallpaper_file="$cache/current_wallpaper"
wallpaper=""
if [[ -s "$wallpaper_file" ]]; then
    IFS= read -r wallpaper < "$wallpaper_file" || true
fi

if [[ ! -f "$wallpaper" ]]; then
    wallpaper_folder="$home/.config/1f2l-dotfiles/Wallpapers"
    folder_setting="$home/.config/1f2l/wallpaper-folder"
    if [[ -s "$folder_setting" ]]; then
        IFS= read -r wallpaper_folder < "$folder_setting" || true
        wallpaper_folder="${wallpaper_folder//\$HOME/$home}"
        wallpaper_folder="${wallpaper_folder//\~/$home}"
    fi

    if [[ -d "$wallpaper_folder" ]]; then
        while IFS= read -r -d '' candidate; do
            wallpaper="$candidate"
            break
        done < <(find "$wallpaper_folder" -maxdepth 1 -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0 | sort -z)
    fi
fi

if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
    printf '%s\n' "$wallpaper" > "$wallpaper_file"
    "$scripts/wallpaper.sh" "$wallpaper" &
else
    printf 'No wallpaper found; skipping wallpaper setup. Choose an image in %s.\n' \
        "$home/.config/1f2l/wallpaper-folder" >&2
fi

interval=$(tr -d '[:space:]' < "$home/.config/1f2l/wallpaper-automation")
if [[ "$interval" =~ ^[1-9][0-9]*$ ]]; then
    run_step "$scripts/wallpaper-automation.sh" --start
fi
