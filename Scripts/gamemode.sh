#!/usr/bin/env bash
#                                      __   
#   ___ ____ ___ _  ___ __ _  ___  ___/ /__ 
#  / _ `/ _ `/  ' \/ -_)  ' \/ _ \/ _  / -_)
#  \_, /\_,_/_/_/_/\__/_/_/_/\___/\_,_/\__/ 
# /___/                                     
# 


wallpaper_cache="$HOME/.cache/1f2l-dotfiles"

# Notifications
source "$HOME/.config/1f2l-dotfiles/Scripts/notifications.sh"
APP_NAME="System"
NOTIFICATION_ICON="joystick"

if [ -f $HOME/.config/1f2l/gamemode-enabled ]; then
  if [ -f $wallpaper_cache/restart-wpauto ]; then
    rm $wallpaper_cache/restart-wpauto
    $HOME/.config/1f2l-dotfiles/Scripts/wallpaper-automation.sh &
  fi
  hyprctl reload
  rm $HOME/.config/1f2l/gamemode-enabled
  notify_user --a "${APP_NAME}" \
            --i "${NOTIFICATION_ICON}" \
            --s "Gamemode deactivated" \
            --m "Animations and blur are now enabled."
else
  if [ -f $wallpaper_cache/wallpaper-automation ]; then
    touch $wallpaper_cache/restart-wpauto
    $HOME/.config/1f2l-dotfiles/Scripts/wallpaper-automation.sh
  fi
  hyprctl eval "activate_gamemode()"
  touch $HOME/.config/1f2l/gamemode-enabled
  notify_user --a "${APP_NAME}" \
          --i "${NOTIFICATION_ICON}" \
          --s "Gamemode activated" \
          --m "Animations and blur are now disabled."
fi