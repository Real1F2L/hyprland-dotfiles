#!/usr/bin/env bash
set -Eeuo pipefail

if (( $# != 1 )); then
    printf 'Usage: %s IMAGE\n' "${0##*/}" >&2
    exit 2
fi

image="$1"
if [[ ! -f "$image" ]]; then
    printf 'Wallpaper image does not exist: %s\n' "$image" >&2
    exit 1
fi
if ! command -v magick >/dev/null 2>&1; then
    printf 'Cannot measure wallpaper brightness: ImageMagick magick is not installed.\n' >&2
    exit 127
fi

brightness="$(magick "$image" -auto-orient -resize '64x64!' -colorspace Gray \
    -format '%[fx:mean]' info:)"
if [[ ! "$brightness" =~ ^(0([.][0-9]+)?|1([.]0+)?)$ ]]; then
    printf 'ImageMagick returned an invalid brightness value for %s: %s\n' \
        "$image" "$brightness" >&2
    exit 1
fi

output="$HOME/.config/waybar/wallpaper-brightness.css"
mkdir -p -- "$(dirname -- "$output")"
temporary="$(mktemp "${output}.XXXXXX")"
trap 'rm -f -- "$temporary"' EXIT

if awk -v brightness="$brightness" 'BEGIN { exit !(brightness >= 0.62) }'; then
    cat > "$temporary" <<'CSS'
/* Bright wallpaper detected; darken Waybar surfaces for contrast. */
window#waybar .modules-left,
window#waybar .modules-center,
window#waybar .modules-right {
    background-color: rgba(0, 0, 0, 0.72);
}

window#waybar .modules-left > widget:hover,
window#waybar .modules-center > widget:hover,
window#waybar .modules-right > widget:hover {
    background-color: alpha(@surface_container_highest, 0.65);
}
CSS
    printf 'Bright wallpaper (mean luminance %s): Waybar background enabled.\n' \
        "$brightness"
else
    printf '/* Wallpaper brightness below threshold (mean luminance %s). */\n' \
        "$brightness" > "$temporary"
    printf 'Wallpaper brightness below threshold (mean luminance %s): Waybar background disabled.\n' \
        "$brightness"
fi

mv -f -- "$temporary" "$output"
trap - EXIT
