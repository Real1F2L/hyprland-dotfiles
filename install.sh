#!/usr/bin/env bash
set -Eeuo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
backup_root="$HOME/.local/state/1f2l-dotfiles/backups"
manifest_name="manifest"

usage() {
    cat <<'EOF'
Usage:
  ./install.sh [install]
  ./install.sh undo [backup-directory]

Install backs up every target it replaces before copying the dotfiles.
Run install from an active Hyprland session to detect monitors for workspace groups.
Undo restores the most recent install backup, or the specified backup directory.
EOF
}

config_dirs=(
    "bashrc:.config/bashrc"
    "btop:.config/btop"
    "fish:.config/fish"
    "gtk-3.0:.config/gtk-3.0"
    "gtk-4.0:.config/gtk-4.0"
    "hypr:.config/hypr"
    "kitty:.config/kitty"
    "matugen:.config/matugen"
    "nwg-dock-hyprland:.config/nwg-dock-hyprland"
    "ohmyposh:.config/ohmyposh"
    "qt6ct:.config/qt6ct"
    "quickshell:.config/quickshell"
    "rofi:.config/rofi"
    "settings:.config/1f2l"
    "swaync:.config/swaync"
    "vim:.config/vim"
    "walker:.config/walker"
    "waybar:.config/waybar"
    "waypaper:.config/waypaper"
    "wlogout:.config/wlogout"
    "xsettingsd:.config/xsettingsd"
    "zshrc:.config/zshrc"
    "chromium-flags.conf:.config/chromium-flags.conf"
    "edge-flags.conf:.config/edge-flags.conf"
    ".bashrc:.bashrc"
    ".gtkrc-2.0:.gtkrc-2.0"
    ".Xresources:.Xresources"
    ".zshrc:.zshrc"
    "Scripts:.config/1f2l-dotfiles/Scripts"
)

obsolete_targets=(
    ".config/ml4w"
    ".config/ml4w-dotfiles-installer"
    ".config/ml4w-dotfiles-settings"
    ".config/ml4w-statusbar"
    ".local/share/ml4w-dotfiles"
    ".local/share/ml4w-dotfiles-settings"
    ".local/share/1f2l-dotfiles"
)

detect_monitors() {
    local monitor_json

    if ! command -v hyprctl >/dev/null 2>&1; then
        printf 'Cannot detect monitors: hyprctl is not installed.\n' >&2
        return 1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        printf 'Cannot detect monitors: jq is not installed.\n' >&2
        return 1
    fi
    if ! monitor_json="$(hyprctl monitors -j)"; then
        printf 'Cannot detect monitors. Run the installer from an active Hyprland session.\n' >&2
        return 1
    fi
    if ! jq -e 'type == "array" and length > 0 and all(.[]; (.name | type == "string" and length > 0) and (.x | type == "number"))' \
        <<< "$monitor_json" >/dev/null; then
        printf 'Hyprland did not return a valid list of connected monitors.\n' >&2
        return 1
    fi

    jq -er 'sort_by(.x) | .[].name' <<< "$monitor_json"
}

chmod_installed_scripts() {
    local directory file first_line

    for directory in "$HOME/.config/1f2l" "$HOME/.config/1f2l-dotfiles/Scripts"; do
        [[ -d "$directory" ]] || continue

        while IFS= read -r -d '' file; do
            chmod a+x -- "$file"
        done < <(find "$directory" -type f -name '*.sh' -print0)

        if [[ "$directory" == "$HOME/.config/1f2l-dotfiles/Scripts" ]]; then
            while IFS= read -r -d '' file; do
                IFS= read -r first_line < "$file" || true
                if [[ "$first_line" == '#!'* ]]; then
                    chmod a+x -- "$file"
                fi
            done < <(find "$directory" -type f -print0)
        fi
    done
}

record_target() {
    local target="$1"
    local existed=0
    local saved_path="$backup_dir/objects/$backup_index"

    if [[ -e "$target" || -L "$target" ]]; then
        existed=1
    fi

    printf '%s\0%s\0%s\0' "$target" "$existed" "$saved_path" >> "$backup_dir/$manifest_name"
    if (( existed )); then
        mv -- "$target" "$saved_path"
    fi
    backup_index=$((backup_index + 1))
}

install_project() {
    local mapping source target relative monitor
    local detected_monitors monitor_summary

    for mapping in "${config_dirs[@]}"; do
        source="$project_dir/${mapping%%:*}"
        relative="${mapping#*:}"
        if [[ ! -e "$source" && ! -L "$source" ]]; then
            printf 'Missing project path: %s\n' "$source" >&2
            exit 1
        fi
    done

    if ! detected_monitors="$(detect_monitors)"; then
        exit 1
    fi
    while IFS= read -r monitor; do
        if [[ ! "$monitor" =~ ^[[:alnum:]_.:-]+$ ]]; then
            printf 'Hyprland returned an invalid monitor name: %s\n' "$monitor" >&2
            exit 1
        fi
    done <<< "$detected_monitors"

    mkdir -p -- "$backup_root"
    backup_dir="$(mktemp -d "$backup_root/backup-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
    mkdir -p -- "$backup_dir/objects"
    : > "$backup_dir/$manifest_name"
    backup_index=0

    trap 'status=$?; if (( status != 0 )); then printf "Install stopped; recover with: %s undo %s\n" "$0" "$backup_dir" >&2; fi; exit "$status"' ERR

    for mapping in "${config_dirs[@]}"; do
        source="$project_dir/${mapping%%:*}"
        target="$HOME/${mapping#*:}"
        record_target "$target"
        mkdir -p -- "$(dirname "$target")"
        cp -a -- "$source" "$target"
    done

    if [[ -d "$project_dir/Wallpapers" ]]; then
        target="$HOME/.config/1f2l-dotfiles/Wallpapers"
        record_target "$target"
        mkdir -p -- "$(dirname "$target")"
        cp -a -- "$project_dir/Wallpapers" "$target"
    else
        printf 'No Wallpapers directory in checkout; keeping existing wallpapers if present.\n'
    fi

    chmod_installed_scripts

    target="$HOME/.config/1f2l/workspace-group-monitors"
    {
        printf '# Generated by install.sh from connected Hyprland monitors, ordered left to right.\n'
        while IFS= read -r monitor; do
            printf '%s\n' "$monitor"
        done <<< "$detected_monitors"
    } > "$target"

    target="$HOME/.cache/1f2l-dotfiles/current_wallpaper.rasi"
    if [[ ! -s "$target" ]]; then
        local default_wallpaper="$HOME/.config/1f2l-dotfiles/Wallpapers/default.jpg"
        if [[ -f "$default_wallpaper" ]]; then
            record_target "$target"
            mkdir -p -- "$(dirname "$target")"
            printf '* { current-image: url("%s", height); }\n' \
                "$default_wallpaper" > "$target"
        fi
    fi

    for relative in "${obsolete_targets[@]}"; do
        record_target "$HOME/$relative"
    done

    printf '%s\n' "$backup_dir" > "$backup_root/latest.tmp"
    mv -f -- "$backup_root/latest.tmp" "$backup_root/latest"
    trap - ERR

    monitor_summary="${detected_monitors//$'\n'/, }"
    printf 'Installed dotfiles. Backup: %s\n' "$backup_dir"
    printf 'Detected workspace-group monitors: %s\n' "$monitor_summary"
    printf 'Undo with: %s undo %s\n' "$0" "$backup_dir"
}

undo_install() {
    local requested="${1:-}"
    local target existed saved_path i
    local -a targets=() states=() saved_paths=()

    if [[ -z "$requested" ]]; then
        if [[ ! -f "$backup_root/latest" ]]; then
            printf 'No install backup found. Provide a backup directory to undo.\n' >&2
            exit 1
        fi
        IFS= read -r requested < "$backup_root/latest"
    elif [[ "$requested" != /* ]]; then
        requested="$backup_root/$requested"
    fi

    backup_dir="$requested"
    if [[ ! -d "$backup_dir" || "$backup_dir" != "$backup_root/"* ]]; then
        printf 'Invalid backup directory: %s\n' "$backup_dir" >&2
        exit 1
    fi
    if [[ -e "$backup_dir/undone" ]]; then
        printf 'This backup has already been undone: %s\n' "$backup_dir" >&2
        exit 1
    fi
    if [[ ! -f "$backup_dir/$manifest_name" ]]; then
        printf 'Backup manifest is missing: %s\n' "$backup_dir/$manifest_name" >&2
        exit 1
    fi

    while IFS= read -r -d '' target &&
          IFS= read -r -d '' existed &&
          IFS= read -r -d '' saved_path; do
        case "$target" in
            "$HOME"/*) ;;
            *)
                printf 'Refusing to restore a target outside HOME: %s\n' "$target" >&2
                exit 1
                ;;
        esac
        targets+=("$target")
        states+=("$existed")
        saved_paths+=("$saved_path")
    done < "$backup_dir/$manifest_name"

    for ((i = ${#targets[@]} - 1; i >= 0; i--)); do
        target="${targets[$i]}"
        existed="${states[$i]}"
        saved_path="${saved_paths[$i]}"

        if [[ "$existed" == "1" && ! -e "$saved_path" && ! -L "$saved_path" ]]; then
            printf 'Backup for %s is missing: %s\n' "$target" "$saved_path" >&2
            exit 1
        fi

        if [[ -e "$target" || -L "$target" ]]; then
            rm -rf -- "$target"
        fi
        if [[ "$existed" == "1" ]]; then
            mkdir -p -- "$(dirname "$target")"
            mv -- "$saved_path" "$target"
        fi
    done

    : > "$backup_dir/undone"
    if [[ -f "$backup_root/latest" ]] && [[ "$(<"$backup_root/latest")" == "$backup_dir" ]]; then
        rm -- "$backup_root/latest"
    fi

    printf 'Restored configuration from %s\n' "$backup_dir"
}

case "${1:-install}" in
    install)
        if (( $# > 1 )); then
            usage >&2
            exit 2
        fi
        install_project
        ;;
    undo)
        if (( $# > 2 )); then
            usage >&2
            exit 2
        fi
        undo_install "${2:-}"
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
