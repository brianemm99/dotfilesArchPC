pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property int gap: 8

    // Hardcoded stub — matugen adapter swaps in here later.
    // NOTE: no token may be named "on" + Capital — QML parses that
    // as a signal handler. Hence fg/fgMuted, not onSurface/...Variant.
    readonly property color surface:     "#1a1b26"
    readonly property color surfaceHigh: "#2a2b3d"
    readonly property color fg:          "#c0caf5"
    readonly property color fgMuted:     "#787c99"
    readonly property color primary:     "#7aa2f7"

    readonly property color barBg: Qt.rgba(surface.r, surface.g, surface.b, 0.87)
    readonly property color barBorder: Qt.darker("#4a4a4a", 1.4)
}
