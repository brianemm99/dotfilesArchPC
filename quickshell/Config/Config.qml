pragma Singleton
import Quickshell

Singleton {
    // --- geometry ---
    readonly property int barHeight:    34
    readonly property int tabWidth:     116
    readonly property int tabDrop:      0
    readonly property int tabDropHover: 30
    readonly property int tabFillet:    12
    readonly property int tabRadius:    8
    readonly property int borderWidth:  1

    // --- type ---
    readonly property string font:     "JetBrainsMono Nerd Font"
    readonly property int    dateSize: 10
    readonly property int    timeSize: 12
    readonly property int    iconSize: 14

    // --- per-monitor ---
    readonly property string fullBarMonitor: "DP-3"

    // --- paths ---
    readonly property string wallpaperDir: "/home/iris/photos/wallpapers"
}
