import QtQuick
import qs.Theme
import qs.Config
import qs.Services

Item {
    id: root

    implicitWidth: 22
    implicitHeight: Config.barHeight

    Text {
        anchors.centerIn: parent
        text: "󰒓"
        color: Panels.settingsOpen ? Theme.primary : Theme.fg
        font.family: Config.font
        font.pixelSize: Config.iconSize + 1
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { Panels.gearHover = true; Notifs.panelOpen = false }
        onExited: Panels.gearHover = false
        onClicked: Panels.pinned = !Panels.pinned
    }
}
