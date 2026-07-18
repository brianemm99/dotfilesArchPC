import Quickshell.Services.Mpris
import Quickshell.Widgets
import QtQuick
import qs.Theme
import qs.Config

Item {
    id: root

    readonly property var player:
        Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null

    visible: player !== null
    implicitWidth: Config.mprisWidth
    implicitHeight: Config.barHeight

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        ClippingRectangle {
            width: 18; height: 18; radius: 4
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
            width: Config.mprisWidth - 26
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

                // Two ways x goes stale:
                // 1. The animation-on-x REPLACES the x binding — a short title
                //    stopping the marquee leaves x stranded off-left.
                // 2. `to`/`duration` are captured when each pass starts — a
                //    track change mid-scroll finishes one wrong-length sweep.
                onTextChanged: {
                    x = 0;
                    if (overflows) scroll.restart();
                }
                onOverflowsChanged: if (!overflows) x = 0
            }
        }
    }

    // Left-click: play/pause. Popup comes later with the control center.
    // No wheel handler — scroll is inert everywhere on this bar.
    MouseArea {
        anchors.fill: parent
        onClicked: root.player?.togglePlaying()
    }
}
