import Quickshell
import QtQuick
import qs.Theme
import qs.Config

Item {
    id: root

    // Bar.qml feeds this into BarSurface so the shape follows the hover.
    property real drop: hover.containsMouse ? Config.tabDropHover : Config.tabDrop
    Behavior on drop {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    implicitWidth: Config.tabWidth
    implicitHeight: Config.barHeight + Config.tabDropHover

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // month/day — sits inside the bar itself
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: (Config.barHeight - implicitHeight) / 2
        text: Qt.formatDateTime(clock.date, "MM/dd")
        color: Theme.fgMuted
        font.family: Config.font
        font.pixelSize: Config.dateSize
    }

    // day + 24h time — sits in the hanging tab, follows the hover drop
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Config.barHeight + (root.drop - implicitHeight) / 2
        text: Qt.formatDateTime(clock.date, "ddd HH:mm")
        color: Theme.fg
        font.family: Config.font
        font.pixelSize: Config.timeSize
    }

    // Hover only for now — the Obsidian click is build step 8.
    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
    }
}
