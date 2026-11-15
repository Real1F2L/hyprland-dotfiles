#!/usr/bin/env bash
set -Eeuo pipefail

if (( $# != 1 )); then
    printf 'Usage: %s {left|right|up|down}\n' "${0##*/}" >&2
    exit 2
fi

direction="$1"
case "$direction" in
    left|right|up|down) ;;
    *)
        printf 'Invalid direction: %s\n' "$direction" >&2
        exit 2
        ;;
esac

window_info="$(hyprctl activewindow -j)"
if ! jq -e '.address != null and (.at | length == 2) and (.size | length == 2)' \
    <<< "$window_info" >/dev/null; then
    printf 'Cannot move window: no active window geometry is available.\n' >&2
    exit 1
fi

monitor_info="$(hyprctl monitors -j)"
current_monitor="$(jq -er '[.[] | select(.focused == true) | .name] |
    if length == 1 then .[0] else error("Expected exactly one focused monitor") end' \
    <<< "$monitor_info")"

target_monitor="$(jq -r \
    --arg current "$current_monitor" \
    --arg direction "$direction" \
    --argjson window "$window_info" '
    def rect:
        . as $monitor |
        (if (($monitor.transform // 0) % 2) == 1
         then $monitor.height / $monitor.scale
         else $monitor.width / $monitor.scale
         end) as $width |
        (if (($monitor.transform // 0) % 2) == 1
         then $monitor.width / $monitor.scale
         else $monitor.height / $monitor.scale
         end) as $height |
        {
            left: $monitor.x,
            top: $monitor.y,
            right: ($monitor.x + $width),
            bottom: ($monitor.y + $height),
            center_x: ($monitor.x + $width / 2),
            center_y: ($monitor.y + $height / 2)
        };

    . as $monitors |
    ($monitors[] | select(.name == $current)) as $source |
    ($source | rect) as $s |
    ($window.at[0]) as $window_x |
    ($window.at[1]) as $window_y |
    ($window.size[0]) as $window_width |
    ($window.size[1]) as $window_height |
    (if $direction == "right" then $s.right - ($window_x + $window_width)
     elif $direction == "left" then $window_x - $s.left
     elif $direction == "down" then $s.bottom - ($window_y + $window_height)
     else $window_y - $s.top
     end) as $edge_distance |
    [
        $monitors[] |
        select(.name != $current) |
        . as $candidate |
        ($candidate | rect) as $t |
        select(
            if $direction == "right" then
                $t.center_x > $s.center_x and
                ([$t.bottom, $s.bottom] | min) - ([$t.top, $s.top] | max) >
                    ([$t.bottom - $t.top, $s.bottom - $s.top] | min) * 0.1
            elif $direction == "left" then
                $t.center_x < $s.center_x and
                ([$t.bottom, $s.bottom] | min) - ([$t.top, $s.top] | max) >
                    ([$t.bottom - $t.top, $s.bottom - $s.top] | min) * 0.1
            elif $direction == "down" then
                $t.center_y > $s.center_y and
                ([$t.right, $s.right] | min) - ([$t.left, $s.left] | max) >
                    ([$t.right - $t.left, $s.right - $s.left] | min) * 0.1
            else
                $t.center_y < $s.center_y and
                ([$t.right, $s.right] | min) - ([$t.left, $s.left] | max) >
                    ([$t.right - $t.left, $s.right - $s.left] | min) * 0.1
            end
        ) |
        {
            name: $candidate.name,
            gap: (if $direction == "right" then $t.left - $s.right
                  elif $direction == "left" then $s.left - $t.right
                  elif $direction == "down" then $t.top - $s.bottom
                  else $s.top - $t.bottom
                  end | abs),
            distance: (if $direction == "right" or $direction == "left"
                       then ($t.center_x - $s.center_x | abs)
                       else ($t.center_y - $s.center_y | abs)
                       end)
        }
    ] |
    sort_by([.gap, .distance]) |
    if length > 0 and $edge_distance <= 80 then .[0].name else "" end
' <<< "$monitor_info")"

if [[ -n "$target_monitor" ]]; then
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ monitor = \"$target_monitor\" }))"
else
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ direction = \"$direction\" }))"
fi
