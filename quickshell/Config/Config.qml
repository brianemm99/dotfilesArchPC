pragma Singleton
import Quickshell

Singleton {
    // --- geometry ---
    readonly property int barHeight:    34
    readonly property int tabWidth:     96
    readonly property int tabDrop:      20
    readonly property int tabDropHover: 26
    readonly property int tabFillet:    10
    readonly property int tabRadius:    10
    readonly property int borderWidth:  1

    // --- type ---
    readonly property string font:     "JetBrainsMono Nerd Font"
    readonly property int    dateSize: 10
    readonly property int    timeSize: 12
    readonly property int    iconSize: 14

    // --- modules ---
    readonly property int mprisWidth: 180

    // --- per-monitor ---
    readonly property string fullBarMonitor: "DP-3"   // <- EDIT: your monitor's name from `hyprctl monitors`

    // --- integrations ---
    readonly property string obsidianAppId: "obsidian"  // <- Opens Obsidian  
}
