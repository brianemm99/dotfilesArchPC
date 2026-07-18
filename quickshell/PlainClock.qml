import Quickshell
import QtQuick
import qs.Theme
import qs.Config

Text {
    text: Qt.formatDateTime(clock.date, "MM/dd  ddd HH:mm")
    color: Theme.fg
    font.family: Config.font
    font.pixelSize: Config.timeSize

    SystemClock { id: clock; precision: SystemClock.Minutes }
}
