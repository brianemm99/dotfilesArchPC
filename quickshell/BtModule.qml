import Quickshell
import Quickshell.Bluetooth
import QtQuick
import qs.Theme
import qs.Config

Item {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.enabled ?? false
    readonly property bool connected:
        Bluetooth.devices.values.some(d => d.connected)

    implicitWidth: 22
    implicitHeight: Config.barHeight

    Text {
        anchors.centerIn: parent
        text: !root.powered ? "󰂲" : root.connected ? "󰂱" : "󰂯"
        color: !root.powered ? Theme.fgMuted
             : root.connected ? Theme.primary : Theme.fg
        font.family: Config.font
        font.pixelSize: Config.iconSize
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["ghostty", "-e", "bluetui"])
    }
}
