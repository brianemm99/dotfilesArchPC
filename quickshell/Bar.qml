pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Config

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        readonly property bool full: modelData.name === Config.fullBarMonitor

        WlrLayershell.namespace: "quickshell:bar"
        anchors { top: true; left: true; right: true }

        readonly property real maxDrop: full
            ? Math.max(power.expandedDrop, clock.expandedDrop, media.expandedDrop) : 0

        implicitHeight: Config.barHeight + maxDrop + Config.borderWidth * 2
        exclusiveZone: Config.barHeight
        color: "transparent"

        mask: Region {
            Region {
                x: 0; y: 0
                width: bar.width
                height: Config.barHeight
            }
            Region {
                x: Math.round(clock.x)
                y: Config.barHeight
                width: clock.width
                height: bar.full ? clock.expandedDrop : 0
            }
            Region {
                x: Math.round(power.x)
                y: Config.barHeight
                width: power.width
                height: bar.full ? power.expandedDrop : 0
            }
            // Pin-only tab: armed only while open (or closing), so no
            // permanent dead strip mid-screen.
            Region {
                x: Math.round(media.x)
                y: Config.barHeight
                width: media.width
                height: (bar.full && media.drop > 0) ? media.expandedDrop : 0
            }
        }

        BarSurface {
            anchors.fill: parent
            tabs: bar.full ? [clock, power, media] : []
        }

        // ── LEFT ──
        PowerButton {
            id: power
            visible: bar.full
            anchors.left: parent.left
            anchors.leftMargin: Theme.gap
            y: 0
        }
        Workspaces {
            screen: bar.modelData
            anchors.left: bar.full ? power.right : parent.left
            anchors.leftMargin: Theme.gap
            y: (Config.barHeight - height) / 2
        }

        // ── CENTER ──
        ClockTab {
            id: clock
            visible: bar.full
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
        }
        MediaTab {
            id: media
            visible: bar.full && media.player !== null
            anchors.left: clock.right
            anchors.leftMargin: Theme.gap * 8
            y: 0
        }
        PlainClock {
            visible: !bar.full
            anchors.horizontalCenter: parent.horizontalCenter
            y: (Config.barHeight - height) / 2
        }

        // ── RIGHT ──
        RowLayout {
            visible: bar.full
            anchors.right: parent.right
            anchors.rightMargin: Theme.gap
            y: 0
            height: Config.barHeight
            spacing: Theme.gap

            AudioModule {}
            Tray {}
        }
    }
}
