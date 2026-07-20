pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: root

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

    // ── Super+Esc: close every shell surface ──
    signal dismissAll()

    GlobalShortcut {
        appid: "quickshell"
        name: "dismiss"
        onPressed: {
            root.closeSettings();
            Notifs.panelOpen = false;
            Notifs.clearToasts();
            root.dismissAll();      // tabs and launcher listen for this
        }
    }
}
