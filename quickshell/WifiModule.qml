import Quickshell
import Quickshell.Io
import QtQuick
import qs.Theme
import qs.Config

Item {
    id: root

    property bool blocked: false

    Process {
        id: check
        command: ["rfkill", "-J"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devs = JSON.parse(text).rfkilldevices ?? [];
                    root.blocked = devs.filter(d => d.type === "wlan")
                        .every(d => d.soft === "blocked");
                } catch (e) { console.warn("wifi rfkill parse:", e); }
            }
        }
    }
    Timer {
        interval: 5000
        repeat: true
        triggeredOnStart: true
        running: true
        onTriggered: check.running = true
    }

    implicitWidth: 22
    implicitHeight: Config.barHeight

    Text {
        anchors.centerIn: parent
        text: root.blocked ? "󰖪" : "󰖩"
        color: root.blocked ? Theme.fgMuted : Theme.fg
        font.family: Config.font
        font.pixelSize: Config.iconSize
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Quickshell.execDetached(["rfkill", root.blocked ? "unblock" : "block", "wlan"]);
            root.blocked = !root.blocked;   // optimistic; poll confirms
        }
    }
}
