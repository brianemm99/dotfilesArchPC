import Quickshell.Services.Pipewire
import QtQuick
import qs.Theme
import qs.Config

Item {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink

    // Without this, Pipewire node properties never populate and volume
    // reads 0 forever. Not optional.
    PwObjectTracker { objects: [ root.sink ] }

    readonly property real vol: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    implicitWidth: label.implicitWidth
    implicitHeight: Config.barHeight

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        text: root.muted ? "muted" : ` ${Math.round(root.vol * 100)}%`
        color: root.muted ? Theme.fgMuted : Theme.fg
        font.family: Config.font
        font.pixelSize: 12
    }

    // Click toggles mute. Volume changes stay on your XF86 keys via
    // hyprland.lua — the bar displays; it doesn't duplicate them.
    MouseArea {
        anchors.fill: parent
        onClicked: { if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted }
    }
}
