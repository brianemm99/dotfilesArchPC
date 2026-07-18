import Quickshell
import QtQuick
import qs.Theme
import qs.Config

TabSlot {
    id: root

    SystemClock { id: clock; precision: SystemClock.Minutes }

    // time — always visible, inline in the bar
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: (Config.barHeight - implicitHeight) / 2
        text: Qt.formatDateTime(clock.date, "ddd HH:mm")
        color: Theme.fg
        font.family: Config.font
        font.pixelSize: Config.timeSize
    }

    // date — revealed in the tab
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Config.barHeight + (root.drop - implicitHeight) / 2
        text: Qt.formatDateTime(clock.date, "MM/dd")
        color: Theme.fgMuted
        font.family: Config.font
        font.pixelSize: Config.dateSize
        opacity: root.reveal
    }
}
