pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Config

RowLayout {
    spacing: Theme.gap

    Repeater {
        model: SystemTray.items

        IconImage {
            required property SystemTrayItem modelData

            // Passive = "nothing to report" per the tray spec; hide those.
            visible: modelData.status !== Status.Passive
            implicitSize: Config.iconSize
            source: modelData.icon

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                onClicked: (m) => {
                    if (m.button === Qt.MiddleButton) modelData.secondaryActivate();
                    else modelData.activate();
                }
            }
        }
    }
}
