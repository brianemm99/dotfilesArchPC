pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: root

    // ── settings panel ──
    property bool pinned: false
    property bool gearHover: false
    property bool panelHover: false
    property bool settingsOpen: false

    readonly property bool wantOpen: pinned || gearHover || panelHover
    onWantOpenChanged: {
        if (wantOpen) { closeTimer.stop(); settingsOpen = true; }
        else closeTimer.restart();
    }

    function closeSettings() {
        pinned = false;
        closeTimer.stop();
        settingsOpen = false;
    }

    Timer {
        id: closeTimer
        interval: 350
        onTriggered: root.settingsOpen = false
    }

    // ── wallpaper picker ──
    property bool wallpaperOpen: false

    function openWallpaper() {
        closeSettings();
        Notifs.panelOpen = false;
        wallpaperOpen = true;
    }

    // ── system monitor panel (hover intent both ways) ──
    property bool sysmonRingsHover: false
    property bool sysmonPanelHover: false
    property bool sysmonOpen: false

    readonly property bool sysmonWant: sysmonRingsHover || sysmonPanelHover
    onSysmonWantChanged: {
        if (sysmonWant) { sysmonClose.stop(); sysmonOpenT.restart(); }
        else { sysmonOpenT.stop(); sysmonClose.restart(); }
    }

    Timer { id: sysmonOpenT; interval: 200; onTriggered: root.sysmonOpen = true }
    Timer { id: sysmonClose; interval: 300; onTriggered: root.sysmonOpen = false }

    // ── global dismiss ──
    signal dismissAll()

    GlobalShortcut {
        appid: "quickshell"
        name: "dismiss"
        onPressed: {
            root.closeSettings();
            root.sysmonOpen = false;
            Notifs.panelOpen = false;
            Notifs.clearToasts();
            root.dismissAll();
        }
    }
}
