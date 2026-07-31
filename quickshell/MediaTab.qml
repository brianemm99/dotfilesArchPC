pragma ComponentBehavior: Bound
import Quickshell.Services.Mpris
import Quickshell.Widgets
import QtQuick
import qs.Theme
import qs.Config
import qs.Services

TabSlot {
    id: root

    // ── THE KNOBS ──
    tabWidth: 516
    readonly property real artSize: 180
    readonly property real waveH:   60          // wave band height
    readonly property real seekH:   24
    readonly property real playSize: 64
    readonly property real skipSize: 48
    readonly property real ctlGap:   18
    readonly property real ctlBottomMargin: 26  // lifts transport + pills

    readonly property real pad: 19
    expandedDrop: pad + artSize + 14 + waveH + pad
    hoverOpens: false
    onBarClicked: pinned = !pinned
    onPinnedChanged: {
        if (!pinned) forcedSource = "";
        Visualizer.active = pinned;             // cava runs only while open
    }

    function srcOf(p) {
        const s = String(p?.dbusName ?? "").toLowerCase();
        if (s.includes("playerctld")) return "proxy";
        if (s.includes("spotify")) return "spotify";
        if (s.includes("brave")) return "browser";
        return "other";
    }

    readonly property var realPlayers:
        Mpris.players.values.filter(p => root.srcOf(p) !== "proxy")

    readonly property var spotifyPlayer:
        realPlayers.find(p => root.srcOf(p) === "spotify") ?? null
    readonly property var browserPlayer:
        realPlayers.find(p => root.srcOf(p) === "browser") ?? null

    property string forcedSource: ""

    property var stickyPlayer: null
    readonly property var playingPlayer:
        realPlayers.find(p => p.isPlaying) ?? null
    onPlayingPlayerChanged: if (playingPlayer) stickyPlayer = playingPlayer

    readonly property var player: {
        if (forcedSource === "spotify" && spotifyPlayer) return spotifyPlayer;
        if (forcedSource === "browser" && browserPlayer) return browserPlayer;
        if (playingPlayer) return playingPlayer;
        if (stickyPlayer && realPlayers.includes(stickyPlayer)) return stickyPlayer;
        return realPlayers.find(p => (p.trackTitle ?? "") !== "")
            ?? realPlayers[0] ?? null;
    }

    readonly property string activeSource: srcOf(player)

    visible: player !== null

    readonly property real len: player?.length ?? 0

    property real posS: 0
    Timer {
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: root.player !== null && !seekArea.pressed
        onTriggered: root.posS = root.player?.position ?? 0
    }

    readonly property real frac: len > 0
        ? Math.max(0, Math.min(1, (seekArea.pressed ? seekArea.dragFrac : posS / len)))
        : 0

    function fmtTime(s) {
        s = Math.max(0, Math.round(s));
        const m = Math.floor(s / 60), r = s % 60;
        return `${m}:${r < 10 ? "0" : ""}${r}`;
    }

    component ControlButton: Rectangle {
        id: btn
        property string glyph
        property real glyphSize: 18
        signal pressed()

        radius: width / 2
        color: btnHover.containsMouse
            ? Qt.lighter(Theme.surfaceHigh, 1.25) : Theme.surfaceHigh
        Behavior on color { ColorAnimation { duration: 90 } }

        Text {
            anchors.centerIn: parent
            text: btn.glyph
            color: Theme.fg
            font.family: Config.font
            font.pixelSize: btn.glyphSize
        }

        MouseArea {
            id: btnHover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.pressed()
        }
    }

    component SourcePill: Rectangle {
        id: pill
        property string glyph: ""
        property string label
        property bool active: false
        property bool available: true
        signal picked()

        width: pillRow.implicitWidth + 20
        height: 26
        radius: height / 2
        color: !available ? "transparent"
             : active ? Theme.primary
             : pillHover.containsMouse ? Qt.lighter(Theme.surfaceHigh, 1.25)
             : Theme.surfaceHigh
        border.width: available ? 0 : 1
        border.color: Theme.surfaceHigh
        opacity: available ? 1 : 0.45
        Behavior on color { ColorAnimation { duration: 90 } }

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: pill.glyph === "" ? 0 : 6
            Text {
                visible: pill.glyph !== ""
                width: visible ? implicitWidth : 0
                text: pill.glyph
                color: pill.active ? Theme.surface : Theme.fg
                font.family: Config.font
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: pill.label
                color: pill.active ? Theme.surface : Theme.fgMuted
                font.family: Config.font
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: pillHover
            anchors.fill: parent
            hoverEnabled: pill.available
            enabled: pill.available
            onClicked: pill.picked()
        }
    }

    // ── in-bar face ──
    Row {
        x: 12
        height: Config.barHeight
        spacing: 8

        ClippingRectangle {
            width: 18; height: 18; radius: 4
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter
            visible: (root.player?.trackArtUrl ?? "") !== ""
            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        Item {
            id: viewport
            width: root.tabWidth - 12 - 18 - 8 - 12
            height: label.implicitHeight
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            Text {
                id: label
                text: `${root.player?.trackTitle ?? ""} — ${root.player?.trackArtist ?? ""}`
                color: Theme.fg
                font.family: Config.font
                font.pixelSize: 12

                readonly property bool overflows: implicitWidth > viewport.width

                SequentialAnimation on x {
                    id: scroll
                    running: label.overflows
                    loops: Animation.Infinite
                    PauseAnimation { duration: 2500 }
                    NumberAnimation {
                        to: viewport.width - label.implicitWidth
                        duration: Math.max(1, label.implicitWidth - viewport.width) * 28
                        easing.type: Easing.Linear
                    }
                    PauseAnimation { duration: 2500 }
                    NumberAnimation { to: 0; duration: 350; easing.type: Easing.InOutQuad }
                }
                onTextChanged: { x = 0; if (overflows) scroll.restart(); }
                onOverflowsChanged: if (!overflows) x = 0
            }
        }
    }

    // ── revealed panel ──
    Item {
        id: panel
        x: root.pad
        y: Config.barHeight + root.pad
        width: root.tabWidth - root.pad * 2
        height: root.expandedDrop - root.pad * 2
        opacity: root.reveal
        visible: root.reveal > 0.05

        ClippingRectangle {
            id: art
            anchors.left: parent.left
            anchors.top: parent.top
            width: root.artSize; height: root.artSize; radius: 12
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Theme.surfaceHigh
                visible: (root.player?.trackArtUrl ?? "") === ""
                Text {
                    anchors.centerIn: parent
                    text: "󰝚"
                    color: Theme.fgMuted
                    font.family: Config.font
                    font.pixelSize: root.artSize * 0.3
                }
            }
            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: (root.player?.trackArtUrl ?? "") !== ""
            }
        }

        Item {
            id: transport
            anchors.left: art.right
            anchors.right: parent.right
            anchors.bottom: art.bottom
            anchors.bottomMargin: root.ctlBottomMargin
            height: root.playSize

            Row {
                anchors.centerIn: parent
                spacing: root.ctlGap

                ControlButton {
                    width: root.skipSize; height: width
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "󰒮"
                    glyphSize: 21
                    onPressed: root.player?.previous()
                }
                ControlButton {
                    width: root.playSize; height: width
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: root.player?.isPlaying ? "󰏤" : "󰐊"
                    glyphSize: 29
                    onPressed: root.player?.togglePlaying()
                }
                ControlButton {
                    width: root.skipSize; height: width
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "󰒭"
                    glyphSize: 21
                    onPressed: root.player?.next()
                }
            }
        }

        Row {
            anchors.horizontalCenter: transport.horizontalCenter
            anchors.bottom: transport.top
            anchors.bottomMargin: 12
            spacing: 8

            SourcePill {
                glyph: ""
                label: "Spotify"
                available: root.spotifyPlayer !== null
                active: root.activeSource === "spotify"
                onPicked: root.forcedSource = "spotify"
            }
            SourcePill {
                label: "Browser"
                available: root.browserPlayer !== null
                active: root.activeSource === "browser"
                onPicked: root.forcedSource = "browser"
            }
        }

        // ── wave band: spans the panel's lower area ──
        Wave {
            id: wave
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: root.waveH
            values: Visualizer.values
            visible: root.reveal > 0.05
        }

        // ── seek + timestamps, floating on the wave ──
        Text {
            id: tElapsed
            anchors.left: parent.left
            anchors.verticalCenter: seek.verticalCenter
            text: root.fmtTime(seekArea.pressed ? seekArea.dragFrac * root.len : root.posS)
            color: Theme.fgMuted
            font.family: Config.font
            font.pixelSize: 11
        }
        Text {
            id: tTotal
            anchors.right: parent.right
            anchors.verticalCenter: seek.verticalCenter
            text: root.fmtTime(root.len)
            color: Theme.fgMuted
            font.family: Config.font
            font.pixelSize: 11
        }

        Item {
            id: seek
            anchors.left: tElapsed.right
            anchors.right: tTotal.left
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.verticalCenter: wave.verticalCenter
            height: root.seekH

            readonly property bool live: seekArea.containsMouse || seekArea.pressed
            readonly property real trackH: live ? 7 : 5

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: seek.trackH; radius: height / 2
                color: Theme.surfaceHigh
                Behavior on height { NumberAnimation { duration: 100 } }
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * root.frac; height: seek.trackH; radius: height / 2
                color: Theme.primary
                Behavior on height { NumberAnimation { duration: 100 } }
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(parent.width - width, parent.width * root.frac - width / 2))
                width: 13; height: 13; radius: 6.5
                color: Theme.fg
                opacity: seek.live ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 100 } }
            }

            MouseArea {
                id: seekArea
                anchors.fill: parent
                hoverEnabled: true
                property real dragFrac: 0
                function fracAt(mx) {
                    return Math.max(0, Math.min(1, mx / width));
                }
                onPressed: (m) => dragFrac = fracAt(m.x)
                onPositionChanged: (m) => { if (pressed) dragFrac = fracAt(m.x) }
                onReleased: {
                    if (root.player && root.len > 0 && (root.player.canSeek ?? true)) {
                        root.player.position = dragFrac * root.len;
                        root.posS = dragFrac * root.len;
                    }
                }
            }
        }
    }
}
