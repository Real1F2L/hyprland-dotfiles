import Quickshell
import QtQuick

// Opens the configured terminal.
BarButton {
    iconSrc: "../shared/icons/terminal.svg"
    onClicked: {
        Quickshell.execDetached(["bash", "-c",
            Quickshell.env("HOME") + "/.config/1f2l/terminal.sh"])
    }
}
