pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.Theme
import qs.Config
import qs.Services

PanelWindow {
    id: root

    readonly property var targetScreen: {
        const s = Quickshell.screens;
        for (let i = 0; i < s.length; i++)
            if (s[i].name === Config.fullBarMonitor) return s[i];
        return null;
    }
    screen: targetScreen

    property real slide: Panels.sysmonOpen ? 1 : 0
    Behavior on slide {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }
    visible: slide > 0.001

    WlrLayershell.namespace: "quickshell:sysmon"
    anchors { top: true; left: true }
    margins.top: 6
    exclusiveZone: 0

    readonly property real fil: Config.tabFillet
    readonly property real rowH: 92
    readonly property real pad: 16

    implicitWidth: 290
    implicitHeight: rowH * 3 + pad * 2 + fil * 2
    color: "transparent"

    HoverHandler {
        onHoveredChanged: Panels.sysmonPanelHover = hovered
    }

    Connections {
        target: Panels
        function onDismissAll() { Panels.sysmonOpen = false }
    }

    component MetricRow: Item {
        property string label
        property real pct
        property string detail

        width: parent.width
        height: root.rowH

        Ring {
            id: bigRing
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            ringSize: 68
            stroke: 7
            labelSize: 17
            pct: parent.pct
        }

        Column {
            anchors.left: bigRing.right
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: parent.parent.label
                color: Theme.fg
                font.family: Config.font
                font.pixelSize: 13
            }
            Text {
                text: parent.parent.detail
                color: Theme.fgMuted
                font.family: Config.font
                font.pixelSize: 11
            }
        }
    }

    Item {
        id: slider
        width: parent.width
        height: parent.height
        x: -(1 - root.slide) * root.width

        EdgePanelSurface {
            anchors.fill: parent
            mirrored: true
        }

        Column {
            x: root.pad
            y: root.fil + root.pad
            width: slider.width - root.pad * 2
            spacing: 0

            MetricRow {
                label: "GPU"
                pct: SysMon.gpuPct
                detail: SysMon.hasGpu
                    ? SysMon.fmtBytes(SysMon.vramUsed) + " / " + SysMon.fmtBytes(SysMon.vramTotal)
                    : "unavailable"
            }
            MetricRow {
                label: "CPU"
                pct: SysMon.cpuPct
                detail: (SysMon.cpuTemp > 0 ? SysMon.cpuTemp.toFixed(0) + "°C · " : "")
                    + "load " + SysMon.load1.toFixed(2)
                    + (SysMon.cores > 0 ? " / " + SysMon.cores : "")
            }
            MetricRow {
                label: "RAM"
                pct: SysMon.memPct
                detail: SysMon.fmtBytes(SysMon.memUsed) + " / " + SysMon.fmtBytes(SysMon.memTotal)
            }
        }
    }
}
