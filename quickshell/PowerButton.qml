pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.Theme
import qs.Config

TabSlot {
    id: root

    tabWidth: 46
    expandedDrop: 186
    hoverOpens: false           // pin-only: click or Super+M — no transit-flash
    onBarClicked: pinned = !pinned

    readonly property var entries: [
        { icon: "⏻",  cmd: ["systemctl", "poweroff"]  },
        { icon: "󰜉", cmd: ["systemctl", "reboot"]    },
        { icon: "󰒲", cmd: ["systemctl", "suspend"]   },
        { icon: "󰓡", cmd: ["systemctl", "hibernate"] },
        { icon: "󰍃", cmd: null }
    ]

    function run(entry) {
        pinned = false;
        if (entry.cmd === null) Hyprland.dispatch("hl.dsp.exit()");
        else Quickshell.execDetached(entry.cmd);
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "powermenu"
        onPressed: root.pinned = !root.pinned
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: (Config.barHeight - implicitHeight) / 2
        text: "󰣇"
        color: Theme.primary
        font.family: Config.font
        font.pixelSize: Config.iconSize + 2
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Config.barHeight + 6
        spacing: 2
        opacity: root.reveal
        visible: root.reveal > 0.05

        Repeater {
            model: root.entries

            Rectangle {
                required property var modelData
                width: 34
                height: 32
                radius: 6
                color: rowHover.containsMouse ? Theme.surfaceHigh : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData.icon
                    color: Theme.fg
                    font.family: Config.font
                    font.pixelSize: Config.iconSize + 1
                }

                MouseArea {
                    id: rowHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.run(parent.modelData)
                }
            }
        }
    }
}
