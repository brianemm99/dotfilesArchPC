pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property int gap: 8

    FileView {
        id: file
        path: Qt.resolvedUrl("./colors.json")
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter
            property string surface:     "#1a1b26"
            property string surfaceHigh: "#2a2b3d"
            property string fg:          "#c0caf5"
            property string fgMuted:     "#787c99"
            property string primary:     "#7aa2f7"
            property string outline:     "#4a4a4a"
        }
    }

    readonly property color surface:     adapter.surface
    readonly property color surfaceHigh: adapter.surfaceHigh
    readonly property color fg:          adapter.fg
    readonly property color fgMuted:     adapter.fgMuted
    readonly property color primary:     adapter.primary

    // Structural derivations stay ours — matugen supplies raw material.
    readonly property color barBg: Qt.rgba(
        surface.r, surface.g, surface.b, 0.87)
    readonly property color barBorder: Qt.darker(adapter.outline, 1.4)
}
