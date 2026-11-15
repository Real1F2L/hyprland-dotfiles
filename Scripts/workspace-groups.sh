#!/usr/bin/env bash
set -Eeuo pipefail

monitor_file="$HOME/.config/1f2l/workspace-group-monitors"
group_count=9

usage() {
    printf 'Usage: %s {switch|move} <group 1-%s>\n' "${0##*/}" "$group_count"
}

if (( $# != 2 )); then
    usage >&2
    exit 2
fi

if [[ ( "$1" != "switch" && "$1" != "move" ) || ! "$2" =~ ^[1-9]$ ]]; then
    usage >&2
    exit 2
fi

action="$1"
group="$2"
if (( group > group_count )); then
    usage >&2
    exit 2
fi

if [[ ! -r "$monitor_file" ]]; then
    printf 'Cannot read monitor list: %s\n' "$monitor_file" >&2
    exit 1
fi

mapfile -t monitors < <(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
    -e '/^#/d' -e '/^$/d' "$monitor_file")
if (( ${#monitors[@]} == 0 )); then
    printf 'No monitors configured in %s\n' "$monitor_file" >&2
    exit 1
fi

declare -A configured=()
for monitor in "${monitors[@]}"; do
    if [[ ! "$monitor" =~ ^[[:alnum:]_.:-]+$ ]]; then
        printf 'Invalid monitor name in %s: %s\n' "$monitor_file" "$monitor" >&2
        exit 1
    fi
    if [[ -n "${configured[$monitor]:-}" ]]; then
        printf 'Duplicate monitor in %s: %s\n' "$monitor_file" "$monitor" >&2
        exit 1
    fi
    configured["$monitor"]=1
done

monitor_info="$(hyprctl monitors -j)"
for monitor in "${monitors[@]}"; do
    if ! jq -e --arg monitor "$monitor" 'any(.[]; .name == $monitor)' \
        <<< "$monitor_info" >/dev/null; then
        printf 'Configured monitor is not connected: %s\n' "$monitor" >&2
        printf 'Update %s to match `hyprctl monitors`.\n' "$monitor_file" >&2
        exit 1
    fi
done

focused_monitor="$(jq -er '.[] | select(.focused == true) | .name' <<< "$monitor_info")"
monitor_count=${#monitors[@]}

if [[ "$action" == "move" ]]; then
    monitor_index=-1
    for i in "${!monitors[@]}"; do
        if [[ "${monitors[$i]}" == "$focused_monitor" ]]; then
            monitor_index=$i
            break
        fi
    done
    if (( monitor_index < 0 )); then
        printf 'Focused monitor is not configured for workspace groups: %s\n' \
            "$focused_monitor" >&2
        exit 1
    fi

    workspace=$(( (group - 1) * monitor_count + monitor_index + 1 ))
    hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = $workspace }))"
    exit
fi

lua=""
for i in "${!monitors[@]}"; do
    monitor="${monitors[$i]}"
    workspace=$(( (group - 1) * monitor_count + i + 1 ))
    current_workspace="$(jq -er --arg monitor "$monitor" \
        '.[] | select(.name == $monitor) | .activeWorkspace.id' <<< "$monitor_info")"
    if (( current_workspace != workspace )); then
        lua+="hl.dispatch(hl.dsp.focus({ monitor = \"$monitor\" }));"
        lua+="hl.dispatch(hl.dsp.focus({ workspace = \"$workspace\" }));"
    fi
done
lua+="hl.dispatch(hl.dsp.focus({ monitor = \"$focused_monitor\" }))"
hyprctl eval "$lua"
