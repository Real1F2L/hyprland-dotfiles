#!/usr/bin/env bash

SAVE_DIR="$HOME/Pictures"
SAVE_FILENAME="screenshot_$(date +%d%m%Y_%H%M%S).jpg"

# Load settings
if [[ -f ~/.config/1f2l/screenshot-folder ]]; then
    SAVE_DIR=$(cat ~/.config/1f2l/screenshot-folder)
fi

if [[ -f ~/.config/1f2l/screenshot-filename ]]; then
    SAVE_FILENAME=$(cat ~/.config/1f2l/screenshot-filename)
fi

eval screenshot_folder="$SAVE_DIR"
eval NAME="$SAVE_FILENAME"

image_format="png"
extension="${NAME##*.}"

case "$extension" in
    jpg|jpeg) image_format="jpeg" ;;
    ppm)      image_format="ppm" ;;
esac

# Notifications
source "$HOME/.config/1f2l-dotfiles/Scripts/notifications.sh"

APP_NAME="Screen Capture"
NOTIFICATION_ICON="camera-photo-symbolic"

export GRIMBLAST_EDITOR="$(cat ~/.config/1f2l/screenshot-editor 2>/dev/null)"

# -----------------------------------------------------
# Clipboard capture

capture_clipboard() {
    local screenshot

    screenshot=$(mktemp --suffix=.png) || return 1

    if grimblast save "$option_type_screenshot" "$screenshot"; then
        if wl-copy --type image/png < "$screenshot"; then
            notify_user \
                --a "$APP_NAME" \
                --i "$NOTIFICATION_ICON" \
                --s "Screenshot copied" \
                --m "Image saved to clipboard" \
                --t 1000
        else
            notify_user \
                --a "$APP_NAME" \
                --i "$NOTIFICATION_ICON" \
                --s "Clipboard failed" \
                --m "Could not copy screenshot" \
                --t 2000
        fi
    fi

    rm -f "$screenshot"
}

# -----------------------------------------------------
# Instant full screenshot

take_instant_full() {
    grim -t "$image_format" "$NAME" && {
        wl-copy --type image/png < "$NAME"
        notify_user \
            --a "$APP_NAME" \
            --i "$NOTIFICATION_ICON" \
            --s "Screenshot copied" \
            --m "Screenshot saved to clipboard" \
            --t 1000
    }
}

# -----------------------------------------------------
# Instant area screenshot

take_instant_area() {
    local pid_picker region

    hyprpicker -r -z &
    pid_picker=$!
    trap 'kill "$pid_picker" 2>/dev/null' EXIT

    sleep 0.1

    region=$(slurp -b "#00000080" -c "#888888ff" -w 1) || exit 0
    [[ -z "$region" ]] && exit 0

    kill "$pid_picker" 2>/dev/null
    trap - EXIT

    grim -g "$region" -t png "$NAME" && {
        wl-copy --type image/png < "$NAME"
        notify_user \
            --a "$APP_NAME" \
            --i "$NOTIFICATION_ICON" \
            --s "Screenshot copied" \
            --m "Screenshot saved to clipboard" \
            --t 1000
    }
}

# -----------------------------------------------------
# Instant flags

if [[ "$1" == "--instant" ]]; then
    take_instant_full
    exit 0
elif [[ "$1" == "--instant-area" ]]; then
    take_instant_area
    exit 0
elif [[ "$1" == "--clipboard" ]]; then
    option_type_screenshot="screen"
    capture_clipboard
    exit 0
fi

# -----------------------------------------------------
# Options

option_1="Immediate"
option_2="Delayed"

option_capture_1="Capture Everything"
option_capture_2="Capture Active Display"
option_capture_3="Capture Selection"

option_time_1="5s"
option_time_2="10s"
option_time_3="20s"
option_time_4="30s"
option_time_5="60s"

copy="Copy to Clipboard"
save="Save"
copy_save="Copy & Save"
edit="Edit"

# Rofi

rofi_cmd() {
    rofi -dmenu -replace \
        -config ~/.config/rofi/config-screenshot.rasi \
        -i -no-show-icons -l 2 -width 30 \
        -p "Take screenshot"
}

run_rofi() {
    echo -e "$option_1\n$option_2" | rofi_cmd
}

# -----------------------------------------------------
# Timer selection

timer_cmd() {
    rofi -dmenu -replace \
        -config ~/.config/rofi/config-screenshot.rasi \
        -i -no-show-icons -l 5 -width 30 \
        -p "Choose timer"
}

timer_exit() {
    echo -e "$option_time_1\n$option_time_2\n$option_time_3\n$option_time_4\n$option_time_5" | timer_cmd
}

timer_run() {
    selected_timer="$(timer_exit)"

    case "$selected_timer" in
        "$option_time_1") countdown=5 ;;
        "$option_time_2") countdown=10 ;;
        "$option_time_3") countdown=20 ;;
        "$option_time_4") countdown=30 ;;
        "$option_time_5") countdown=60 ;;
        *) exit 0 ;;
    esac

    "$1"
}

# -----------------------------------------------------
# Screenshot type selection

type_screenshot_cmd() {
    rofi -dmenu -replace \
        -config ~/.config/rofi/config-screenshot.rasi \
        -i -no-show-icons -l 3 -width 30 \
        -p "Type of screenshot"
}

type_screenshot_exit() {
    echo -e "$option_capture_1\n$option_capture_2\n$option_capture_3" | type_screenshot_cmd
}

type_screenshot_run() {
    selected_type_screenshot="$(type_screenshot_exit)"

    case "$selected_type_screenshot" in
        "$option_capture_1") option_type_screenshot="screen" ;;
        "$option_capture_2") option_type_screenshot="output" ;;
        "$option_capture_3") option_type_screenshot="area" ;;
        *) exit 0 ;;
    esac

    "$1"
}

# -----------------------------------------------------
# Save / clipboard selection

copy_save_editor_cmd() {
    rofi -dmenu -replace \
        -config ~/.config/rofi/config-screenshot.rasi \
        -i -no-show-icons -l 4 -width 30 \
        -p "How to save"
}

copy_save_editor_exit() {
    echo -e "$copy\n$save\n$copy_save\n$edit" | copy_save_editor_cmd
}

copy_save_editor_run() {
    selected_chosen="$(copy_save_editor_exit)"

    case "$selected_chosen" in
        "$copy")
            option_chosen="copy"
            image_format="png"
            "$1"
            ;;
        "$save")
            option_chosen="save"
            "$1"
            ;;
        "$copy_save")
            option_chosen="copysave"
            image_format="png"
            "$1"
            ;;
        "$edit")
            option_chosen="edit"
            "$1"
            ;;
        *)
            exit 0
            ;;
    esac
}

# -----------------------------------------------------
# Timer

timer() {
    if [[ $countdown -gt 10 ]]; then
        notify_user \
            --a "$APP_NAME" \
            --i "$NOTIFICATION_ICON" \
            --s "Taking screenshot in ${countdown} seconds" \
            --m "" \
            --t 1000

        sleep "$((countdown - 10))"
        countdown=10
    fi

    while [[ $countdown -ne 0 ]]; do
        notify_user \
            --a "$APP_NAME" \
            --i "$NOTIFICATION_ICON" \
            --s "Taking screenshot in ${countdown} seconds" \
            --m "" \
            --t 1000

        countdown=$((countdown - 1))
        sleep 1
    done
}

# -----------------------------------------------------
# Capture

takescreenshot() {
    sleep 1

    if [[ "$option_chosen" == "copy" ]]; then
        capture_clipboard
        return
    fi

    grimblast --notify "$option_chosen" \
        --filetype "$image_format" \
        "$option_type_screenshot" "$NAME"

    if [[ -f "$HOME/$NAME" && -d "$screenshot_folder" ]]; then
        mv "$HOME/$NAME" "$screenshot_folder/"
    fi
}

takescreenshot_timer() {
    sleep 1
    timer
    sleep 1

    if [[ "$option_chosen" == "copy" ]]; then
        capture_clipboard
        return
    fi

    grimblast --notify "$option_chosen" \
        --filetype "$image_format" \
        "$option_type_screenshot" "$NAME"

    if [[ -f "$HOME/$NAME" && -d "$screenshot_folder" ]]; then
        mv "$HOME/$NAME" "$screenshot_folder/"
    fi
}

# -----------------------------------------------------
# Execute

run_cmd() {
    if [[ "$1" == "--opt1" ]]; then
        type_screenshot_run
        copy_save_editor_run "takescreenshot"

    elif [[ "$1" == "--opt2" ]]; then
        timer_run "type_screenshot_run"
        type_screenshot_run
        copy_save_editor_run "takescreenshot_timer"
    fi
}

# -----------------------------------------------------
# Main

chosen="$(run_rofi)"

case "$chosen" in
    "$option_1")
        run_cmd --opt1
        ;;
    "$option_2")
        run_cmd --opt2
        ;;
esac
