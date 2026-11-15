# 1f2l Dotfiles

Personal desktop configuration for a Hyprland session, including Hyprland,
Waybar, Quickshell, GTK, terminal, launcher, notification, and wallpaper
settings.

## Install

Run the installer from an active Hyprland session:

```bash
./install.sh
```

The installer backs up files it replaces under
`~/.local/state/1f2l-dotfiles/backups`, detects connected monitors for workspace
groups, and prints an undo command when finished. To restore the most recent
backup:

```bash
./install.sh undo
```

The installer configures dotfiles; it does not install system packages. The
session expects Hyprland, `hyprctl`, `jq`, and the applications used by the
enabled configuration and scripts to be installed separately.

## Wallpapers

Wallpaper images are intentionally excluded from Git. Put your own images in
`~/.config/1f2l-dotfiles/Wallpapers` or change the folder in
`~/.config/1f2l/wallpaper-folder`. Existing local wallpaper files are retained
when installing from a checkout without a `Wallpapers` directory.

At startup, the session uses the last wallpaper if it still exists; otherwise,
it selects an image from the configured wallpaper folder. If no image is
available, wallpaper setup is skipped while the rest of the session continues.
Matugen updates the themes and Waybar chooses a contrasting background based
on the selected image's brightness.

## Repository notes

Machine-specific Fish variables, GTK bookmarks, editor backups, and the
personal `Wallpapers/` collection are excluded by `.gitignore`.
