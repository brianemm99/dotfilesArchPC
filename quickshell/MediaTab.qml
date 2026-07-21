pragma ComponentBehavior: Bound
import Quickshell.Services.Mpris
import Quickshell.Widgets
import QtQuick
import qs.Theme
import qs.Config

TabSlot {
    id: root

    // ── THE KNOBS ──
    tabWidth: 430
    readonly property real artSize: 140
    readonly property real seekH:   20

    readonly property real pad: 16
    expandedDrop: pad + artSize + 12 + seekH + pad
    hoverOpens: false
    onBarClicked: pinned = !pinned

    // ── sticky player selection (Brave-pause bug fix — keep) ──
    property var stickyPlayer: null
    readonly property var playingPlayer:
        Mpris.players.values.find(p => p.isPlaying) ?? null
    onPlayingPlayerChanged: if (playingPlayer) stickyPlayer = playingPlayer

    readonly property var player: playingPlayer
        ?? ((stickyPlayer && Mpris.players.values.includes(stickyPlayer))
                ? stickyPlayer : null)
        ?? Mpris.players.values.find(p => (p.trackTitle ?? "") !== "")
        ?? Mpris.players.values[0] ?? null

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

    // ── circular control button: the disc IS the click target ──
    component ControlButton: Rectangle {
        id: btn
        property string glyph
        property real glyphSize: 18
        signal pressed()

        radius: width / 2
        color: btnHover.containsMouse
            ? (btnHover.pressedButtons ? Qt.darker(Theme.surfaceHigh, 1.15)
                                       : Qt.lighter(Theme.surfaceHigh, 1.25))
            : Theme.surfaceHigh
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

    // ── in-bar face: art thumb + marquee ──
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
            width: root.artSize; height: root.artSize; radius: 10
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

        // controls — three discs, centered in the zone right of the art
        Item {
            anchors.left: art.right
            anchors.right: parent.right
            anchors.top: art.top
            height: art.height

            Row {
                anchors.centerIn: parent
                spacing: root.artSize * 0.13

                ControlButton {
                    width: root.artSize * 0.34; height: width
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "󰒮"
                    glyphSize: root.artSize * 0.15
                    onPressed: root.player?.previous()
                }
                ControlButton {
                    width: root.artSize * 0.46; height: width
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: root.player?.isPlaying ? "󰏤" : "󰐊"
                    glyphSize: root.artSize * 0.21
                    onPressed: root.player?.togglePlaying()
                }
                ControlButton {
                    width: root.artSize * 0.34; height: width
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: "󰒭"
                    glyphSize: root.artSize * 0.15
                    onPressed: root.player?.next()
                }
            }
        }

        // ── bottom row: elapsed · seek · total ──
        Text {
            id: tElapsed
            anchors.left: parent.left
            anchors.verticalCenter: seek.verticalCenter
            text: root.fmtTime(seekArea.pressed ? seekArea.dragFrac * root.len : root.posS)
            color: Theme.fgMuted
            font.family: Config.font
            font.pixelSize: 10
        }
        Text {
            id: tTotal
            anchors.right: parent.right
            anchors.verticalCenter: seek.verticalCenter
            text: root.fmtTime(root.len)
            color: Theme.fgMuted
            font.family: Config.font
            font.pixelSize: 10
        }

        Item {
            id: seek
            anchors.left: tElapsed.right
            anchors.right: tTotal.left
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
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
