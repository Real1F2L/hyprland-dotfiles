import Quickshell
import QtQuick

// Opens the application launcher.
BarButton {
    iconSrc: "../shared/icons/launcher.svg"
    onClicked: {
        Quickshell.execDetached(["bash", "-c",
            Quickshell.env("HOME") + "/.config/1f2l-dotfiles/Scripts/launcher.sh"])
    }
}
