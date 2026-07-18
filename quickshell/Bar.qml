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

        implicitHeight: Config.barHeight
                      + (full ? Config.tabDropHover : 0)
                      + Config.borderWidth * 2
        exclusiveZone: Config.barHeight
        color: "transparent"

        mask: Region {
            Region {
                x: 0; y: 0
                width: bar.width
                height: Config.barHeight
            }
            Region {
                x: Math.round((bar.width - Config.tabWidth) / 2)
                y: Config.barHeight
                width: Config.tabWidth
                height: bar.full ? Config.tabDropHover : 0
            }
        }

        BarSurface {
            anchors.fill: parent
            drawTab: bar.full
            tabDrop: bar.full ? clock.drop : Config.tabDrop
        }

        // ── LEFT: workspaces ──
        Workspaces {
            screen: bar.modelData
            anchors.left: parent.left
            anchors.leftMargin: Theme.gap
            y: (Config.barHeight - height) / 2
        }

        // ── CENTER: clock tab, with mpris hanging off its right ──
        ClockTab {
            id: clock
            visible: bar.full
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
        }
        MprisModule {
            visible: bar.full
            anchors.left: clock.right
            anchors.leftMargin: Theme.gap * 8
            y: 0
        }
        PlainClock {
            visible: !bar.full
            anchors.horizontalCenter: parent.horizontalCenter
            y: (Config.barHeight - height) / 2
        }

        // ── RIGHT: tray owns the edge ──
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
