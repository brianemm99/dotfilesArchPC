pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property bool pinned: false        // click-toggled; survives mouse leave
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
}
