pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
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

    property real slide: Panels.settingsOpen ? 1 : 0
    Behavior on slide {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }
    visible: slide > 0.001

    WlrLayershell.namespace: "quickshell:settings"
    anchors { top: true; right: true }
    margins.top: 6
    exclusiveZone: 0

    readonly property real fil: Config.tabFillet

    implicitWidth: 340
    implicitHeight: 300 + fil * 2
    color: "transparent"

    HoverHandler {
        onHoveredChanged: Panels.panelHover = hovered
    }

    readonly property real pad: 18
    readonly property real rowH: 34
    readonly property real toggleH: 40

    readonly property var sinkNode: Pipewire.defaultAudioSink
    readonly property var srcNode:  Pipewire.defaultAudioSource
    PwObjectTracker {
        objects: [root.sinkNode, root.srcNode].filter(n => n !== null)
    }

    property bool wifiBlocked: false
    property bool btBlocked: false
    readonly property bool airplane: wifiBlocked && btBlocked

    Process {
        id: rfkillCheck
        command: ["rfkill", "-J"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devs = JSON.parse(text).rfkilldevices ?? [];
                    root.wifiBlocked = devs.filter(d => d.type === "wlan")
                        .every(d => d.soft === "blocked");
                    root.btBlocked = devs.filter(d => d.type === "bluetooth")
                        .every(d => d.soft === "blocked");
                } catch (e) { console.warn("rfkill parse:", e); }
            }
        }
    }
    Timer {
        interval: 2000
        repeat: true
        triggeredOnStart: true
        running: Panels.settingsOpen
        onTriggered: rfkillCheck.running = true
    }

    function setRadio(type, blocked) {
        Quickshell.execDetached(["rfkill", blocked ? "block" : "unblock", type]);
        if (type === "wlan") wifiBlocked = blocked;
        if (type === "bluetooth") btBlocked = blocked;
    }

    component TogglePill: Rectangle {
        property string icon
        property bool on
        signal toggled()

        width: 56; height: root.toggleH
        radius: height / 2
        color: on ? Theme.primary : Theme.surfaceHigh

        Text {
            anchors.centerIn: parent
            text: parent.icon
            color: parent.on ? Theme.surface : Theme.fgMuted
            font.family: Config.font
            font.pixelSize: Config.iconSize + 2
        }
        MouseArea { anchors.fill: parent; onClicked: parent.toggled() }
    }

    component MixRow: Item {
        id: row
        property var node
        property string iconOn: "󰕾"
        property string iconOff: "󰝟"

        readonly property real vol: node?.audio?.volume ?? 0
        readonly property bool muted: node?.audio?.muted ?? false
        readonly property real shownFrac: drag.pressed
            ? drag.dragFrac : Math.max(0, Math.min(1, vol))

        width: parent.width
        height: root.rowH

        Text {
            id: icon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            text: row.muted ? row.iconOff : row.iconOn
            color: row.muted ? Theme.fgMuted : Theme.fg
            font.family: Config.font
            font.pixelSize: Config.iconSize + 1
            MouseArea {
                anchors.fill: parent
                onClicked: { if (row.node?.audio) row.node.audio.muted = !row.node.audio.muted }
            }
        }

        Text {
            id: pct
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            horizontalAlignment: Text.AlignRight
            text: `${Math.round(row.shownFrac * 100)}%`
            color: Theme.fgMuted
            font.family: Config.font
            font.pixelSize: 10
        }

        Item {
            id: track
            anchors.left: icon.right
            anchors.right: pct.left
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            height: 18

            readonly property bool live: drag.containsMouse || drag.pressed
            readonly property real trackH: live ? 7 : 5

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: track.trackH; radius: height / 2
                color: Theme.surfaceHigh
                Behavior on height { NumberAnimation { duration: 100 } }
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * row.shownFrac; height: track.trackH; radius: height / 2
                color: row.muted ? Theme.fgMuted : Theme.primary
                Behavior on height { NumberAnimation { duration: 100 } }
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(parent.width - width, parent.width * row.shownFrac - width / 2))
                width: 13; height: 13; radius: 6.5
                color: Theme.fg
                opacity: track.live ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 100 } }
            }

            MouseArea {
                id: drag
                anchors.fill: parent
                hoverEnabled: true
                property real dragFrac: 0
                function apply(mx) {
                    dragFrac = Math.max(0, Math.min(1, mx / width));
                    if (row.node?.audio) row.node.audio.volume = dragFrac;
                }
                onPressed: (m) => apply(m.x)
                onPositionChanged: (m) => { if (pressed) apply(m.x) }
            }
        }
    }

    Item {
        id: slider
        width: parent.width
        height: parent.height
        x: (1 - root.slide) * root.width

        EdgePanelSurface { anchors.fill: parent }

        Column {
            x: root.pad
            y: root.fil + root.pad
            width: slider.width - root.pad * 2 - 4
            spacing: 12

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                TogglePill {
                    icon: "󰖩"
                    on: !root.wifiBlocked
                    onToggled: root.setRadio("wlan", !root.wifiBlocked)
                }
                TogglePill {
                    icon: "󰂯"
                    on: !root.btBlocked
                    onToggled: root.setRadio("bluetooth", !root.btBlocked)
                }
                TogglePill {
                    icon: "󰀝"
                    on: root.airplane
                    onToggled: {
                        const target = !root.airplane;
                        root.setRadio("wlan", target);
                        root.setRadio("bluetooth", target);
                    }
                }
            }

            Item { width: 1; height: 4 }

            MixRow { node: root.sinkNode }
            MixRow { node: root.srcNode; iconOn: "󰍬"; iconOff: "󰍭" }

            Item { width: 1; height: 2 }

            // ── Wallpaper & Theme → picker ──
            Rectangle {
                width: parent.width
                height: 36
                radius: height / 2
                color: wpHover.containsMouse
                    ? Qt.lighter(Theme.surfaceHigh, 1.25) : Theme.surfaceHigh
                Behavior on color { ColorAnimation { duration: 90 } }

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "󰸉"
                        color: Theme.fg
                        font.family: Config.font
                        font.pixelSize: Config.iconSize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Wallpaper & Theme"
                        color: Theme.fg
                        font.family: Config.font
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: wpHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Panels.openWallpaper()
                }
            }
        }
    }
}
