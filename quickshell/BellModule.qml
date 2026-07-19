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
        text: Notifs.unread > 0 ? "󰂚" : "󰂜"
        color: Notifs.panelOpen ? Theme.primary
             : Notifs.unread > 0 ? Theme.fg : Theme.fgMuted
        font.family: Config.font
        font.pixelSize: Config.iconSize
    }

    Rectangle {
        visible: Notifs.unread > 0 && !Notifs.panelOpen
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 5
        width: Math.max(13, badgeText.implicitWidth + 6)
        height: 13
        radius: 6.5
        color: Theme.primary
        Text {
            id: badgeText
            anchors.centerIn: parent
            text: Math.min(Notifs.unread, 99)
            color: Theme.surface
            font.family: Config.font
            font.pixelSize: 8
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Notifs.panelOpen = !Notifs.panelOpen;
            if (Notifs.panelOpen) Panels.closeSettings();
        }
    }
}
