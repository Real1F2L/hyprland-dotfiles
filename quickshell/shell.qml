//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import "PowerApp"
import "SidebarApp"
import "CalendarApp"
import "WallpaperApp"
import "StatusbarApp"
import "CustomTheme"

ShellRoot {
    // Test IPC tools: qs ipc show

    IpcHandler {
        target: "theme-manager" 
        function reload(): void {
            Theme.reloadTheme()
        }
    }

    PowerWindow {}
    SidebarWindow {}
    CalendarWindow {}
    WallpaperWindow {}
    StatusbarWindow {}
}