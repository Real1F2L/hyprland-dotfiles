-- Keybindings
-- Mod
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Open Application
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"), { description = "Open the terminal" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("brave-browser"), { description = "Open the browser" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nemo"), { description = "Open the filemanager" })

-- Close Window
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/killactive.sh"), { description = "Kill active window" })
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill"), { description = "Quit active window and all open instances" })

-- Fullscreen / maximize
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Toggle Fullscreen" })
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Toggle Maximize Window" })

-- Float window
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle Floating" })
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/toggle-all-float.sh"), { description = "Toggle floating for all windows of workspace" })

-- Toggle split
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), { description = "Toggle split" })
hl.bind(mainMod .. " + K", hl.dsp.layout("swapsplit"), { description = "Swapsplit" })

-- Toggle pseudo mode
hl.bind(mainMod .. "+ SHIFT + P", hl.dsp.window.pseudo({ action = "toggle" }))

-- Focused window with keyboard
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }), { description = "Move focus left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Move focus right" })
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }), { description = "Move focus up" })
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }), { description = "Move focus down" })

-- Move / resize windows with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window with the mouse" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window with the mouse" })

-- Resize window with keyboard
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { repeating = true }, { description = "Increase window width with keyboard" })
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true }, { description = "Reduce window width with keyboard" })
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { repeating = true }, { description = "Increase window height with keyboard" })
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true }, { description = "Reduce window height with keyboard" })

-- Toggle window group
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Toggle window group" })

-- Cycle through windows inside the group
hl.bind(mainMod .. " + bracketright", hl.dsp.group.next())
hl.bind(mainMod .. " + bracketleft", hl.dsp.group.prev())

-- Move Windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/move-window-direction.sh left"), { description = "Move window left or to the adjacent monitor" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/move-window-direction.sh right"), { description = "Move window right or to the adjacent monitor" })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/move-window-direction.sh up"), { description = "Move window up or to the adjacent monitor" })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/move-window-direction.sh down"), { description = "Move window down or to the adjacent monitor" })

-- Swap Windows
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.swap({ direction = "l" }), { description = "Swap tiled window left" })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.swap({ direction = "r" }), { description = "Swap tiled window right" })
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.swap({ direction = "u" }), { description = "Swap tiled window up" })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.swap({ direction = "d" }), { description = "Swap tiled window down" })


-- Actions

-- Reload hyprland
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland configuration" })

-- Toggle animations
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/toggle-animations.sh"), { description = "Toggle animations" })

-- Screenshot
hl.bind("PRINT", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/screenshot-clipboard.sh --instant-area"), { description = "Take an instant area screenshot and save to clipboard" })
hl.bind(mainMod .. "+ SHIFT + S", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/screenshot-clipboard.sh --instant-area"), { description = "Take an instant area screenshot and save to clipboard" })
hl.bind(mainMod .. "+ SHIFT + CTRL + S", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/screenshot.sh --instant-area"), { description = "Take an instant area screenshot and save to photos" })

-- Power menu
hl.bind(mainMod .. "+ P", hl.dsp.exec_cmd("qs ipc call power toggle"), { description = "Start Power Menu" })

-- Change wallpaper
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/wallpaper-picker.sh"), { description = "Open wallpaper selector" })
-- Toggle wallpaper loop
hl.bind(mainMod .. " + ALT + W", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/wallpaper-automation.sh"), { description = "Toggle wallpaper rotation" })

-- App launcher
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/launcher.sh"), { description = "Open application launcher" })

-- Show keybinds
hl.bind(mainMod .. " + CTRL + K", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/keybindings.sh"), { description = "Show keybindings" })

-- Toggle bar
hl.bind(mainMod .. "+ CTRL + B", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/toggle-waybar.sh"), { description = "Toggle Status Bar" })

-- Clipboard
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/clipboard.sh"), { description = "Open clipboard manager" })

-- Sidebar widget
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("qs ipc call sidebar toggle"), { description = "Open sidebar" })

-- Calendar
hl.bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("qs ipc call calendar toggle"), { description = "Open calendar widget" })


-- hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("qs ipc call statusbar focus"), { description = "Expand statusbar and focus it for keyboard navigation" })

-- Game mode
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/gamemode.sh"), { description = "Toggle game mode" })

-- Lock
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("~/.config/1f2l-dotfiles/Scripts/power-menu.sh -l"), { description = "Lock Screen" })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 2 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Raise volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, description = "Lower volume" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true, description = "Mute audio" })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true, description = "Mute microphone" })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true, description = "Increase brightness" })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true, description = "Decrease brightness" })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Next track" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Pause audio" })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play audio" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Previous track" })
