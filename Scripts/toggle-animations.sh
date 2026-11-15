#!/usr/bin/env bash
set -euo pipefail

cache_file="$HOME/.cache/1f2l-dotfiles/animations-disabled"
mkdir -p "$(dirname "$cache_file")"
if [[ -f "$cache_file" ]]; then
    hyprctl keyword animations:enabled true
    rm -- "$cache_file"
else
    hyprctl keyword animations:enabled false
    : > "$cache_file"
fi
