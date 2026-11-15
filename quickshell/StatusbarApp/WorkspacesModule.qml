import Quickshell.Hyprland
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.CustomTheme

// Hyprland workspace switcher.
RowLayout {
    id: wsRoot
    spacing: 6

    // Number keys select monitor-aware workspace groups.
    property int groupCount: 9

    // The individual workspace buttons, exposed so StatusbarWindow can splice
    // them into its keyboard-navigation list. Rebuilt whenever workspaces are
    // added or removed.
    property var navButtons: []

    function rebuildNavButtons(): void {
        let a = []
        for (let i = 0; i < rep.count; i++)
            a.push(rep.itemAt(i))
        wsRoot.navButtons = a
    }

    // The workspace-group ids to render.
    readonly property var workspaceIds: {
        let ids = []
        for (let id = 1; id <= wsRoot.groupCount; id++)
            ids.push(id)
        return ids
    }

    readonly property int monitorCount: Math.max(1, Hyprland.monitors.values.length)
    readonly property int activeGroup: Hyprland.focusedWorkspace
        ? Math.floor((Hyprland.focusedWorkspace.id - 1) / wsRoot.monitorCount) + 1
        : 1

    // The live Hyprland workspace for an id, or null when it is empty (Hyprland
    // only tracks workspaces that hold windows or are focused).
    function workspaceById(id: int): var {
        const list = Hyprland.workspaces.values
        for (let i = 0; i < list.length; i++)
            if (list[i].id === id)
                return list[i]
        return null
    }

    Repeater {
        id: rep
        model: wsRoot.workspaceIds

        onItemAdded: wsRoot.rebuildNavButtons()
        onItemRemoved: wsRoot.rebuildNavButtons()

        delegate: Rectangle {
            id: ws
            required property var modelData   // the workspace id (int)
            // Set by StatusbarWindow's keyboard navigation.
            property bool focused: false

            // Whether this workspace is the currently focused one.
            readonly property bool isActive: wsRoot.activeGroup === ws.modelData
            // Whether any workspace in this group currently holds a window.
            readonly property bool occupied: {
                const firstWorkspace = (ws.modelData - 1) * wsRoot.monitorCount + 1
                for (let i = 0; i < wsRoot.monitorCount; i++) {
                    const workspace = wsRoot.workspaceById(firstWorkspace + i)
                    if (workspace && workspace.windows > 0)
                        return true
                }
                return false
            }

            // Run this group's action (mouse click or keyboard Return).
            function activate(): void {
                Quickshell.execDetached([
                    Quickshell.env("HOME") + "/.config/1f2l-dotfiles/Scripts/workspace-groups.sh",
                    "switch",
                    String(ws.modelData)
                ])
            }

            implicitWidth: 26
            implicitHeight: 26
            radius: 13

            // Empty, unfocused workspaces are dimmed to set them apart from the
            // ones that hold windows.
            opacity: (ws.isActive || ws.occupied || wsMouse.containsMouse) ? 1 : 0.45
            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutQuint }
            }

            color: ws.isActive
                ? Theme.primary
                : (wsMouse.containsMouse ? Theme.surface_container_high : "transparent")
            border.color: Theme.primary
            border.width: ws.isActive ? 0 : 1

            // Crossfade the fill between active / hover / inactive states so the
            // background of the active circle fades in and the previous one out.
            Behavior on color {
                ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
            }
            // Fade the outline in/out as the fill takes over on activation.
            Behavior on border.width {
                NumberAnimation { duration: 500; easing.type: Easing.OutQuint }
            }

            // Keyboard-selection ring, distinct from the active-workspace fill.
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: width / 2
                color: "transparent"
                border.color: Theme.primary
                border.width: 2
                opacity: ws.focused ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            Text {
                anchors.centerIn: parent
                text: ws.modelData
                color: ws.isActive ? Theme.background : Theme.on_background
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true

                // Match the fill crossfade so the label recolors in step.
                Behavior on color {
                    ColorAnimation { duration: 500; easing.type: Easing.OutQuint }
                }
            }

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ws.activate()
            }
        }
    }
}
