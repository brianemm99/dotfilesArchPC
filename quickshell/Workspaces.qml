pragma ComponentBehavior: Bound
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Config

RowLayout {
    id: root
    required property var screen
    spacing: 4

    readonly property var monitor: Hyprland.monitorFor(root.screen)

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            required property HyprlandWorkspace modelData

            readonly property bool active:
                modelData.id === root.monitor?.activeWorkspace?.id

            visible: modelData.monitor === root.monitor

            implicitWidth: active ? 26 : 10
            implicitHeight: 10
            radius: height / 2
            color: active ? Theme.primary : Theme.surfaceHigh

            Behavior on implicitWidth {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                anchors.fill: parent
		onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${modelData.id} })`)
            }
        }
    }
}
