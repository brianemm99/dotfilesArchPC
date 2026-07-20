pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import qs.Theme
import qs.Config
import qs.Services

PanelWindow {
    id: root

    readonly property var targetScreen: {
        const s = Quickshell.screens;
        for (let i = 0; i < s.length; i++)
            if (s[i].name === Config.fullBarMonitor) return s[i];
        return null;
    }
    screen: targetScreen

    property bool open: false
    visible: open

    WlrLayershell.namespace: "quickshell:launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true }
    margins.top: 280
    exclusiveZone: 0

    implicitWidth: 560
    implicitHeight: 420
    color: "transparent"

    readonly property var pins:
        ["brave", "obsidian", "yazi", "bluetui", "spotify", "discord", "obs", "steam"]

    function pinRank(entry) {
        const n = entry.name.toLowerCase();
        let starts = -1;
        for (let i = 0; i < pins.length; i++) {
            if (n === pins[i]) return i;
            if (starts === -1 && n.startsWith(pins[i])) starts = i;
        }
        return starts;
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "launcher"
        onPressed: {
            root.open = !root.open;
            if (root.open) {
                field.text = "";
                list.currentIndex = 0;
            }
        }
    }

    // click anywhere outside → close
    HyprlandFocusGrab {
        active: root.open
        windows: [ root ]
        onCleared: root.close()
    }

    // Super+Esc closes this too
    Connections {
        target: Panels
        function onDismissAll() { root.close() }
    }

    function close() { root.open = false }

    function launch(entry) {
        if (!entry) return;
        close();
        if (entry.runInTerminal ?? false) {
            const cmd = ["ghostty", "-e"].concat(entry.command);
            Quickshell.execDetached(cmd);
        } else {
            entry.execute();
        }
    }

    readonly property var filtered: {
        const q = field.text.toLowerCase().trim();
        const all = DesktopEntries.applications.values
            .filter(e => !e.noDisplay);

        if (q === "") {
            const pinned = all
                .map(e => ({ e, rank: root.pinRank(e) }))
                .filter(p => p.rank >= 0);
            pinned.sort((a, b) => a.rank - b.rank
                || a.e.name.length - b.e.name.length);
            const seen = new Set();
            const out = [];
            for (const p of pinned) {
                if (!seen.has(p.rank)) { seen.add(p.rank); out.push(p.e); }
            }
            return out;
        }

        const scored = [];
        for (const e of all) {
            const name = e.name.toLowerCase();
            const comment = (e.comment ?? "").toLowerCase();
            let score = -1;
            if (name.startsWith(q)) score = 0;
            else if (name.includes(q)) score = 1;
            else if (comment.includes(q)) score = 2;
            if (score >= 0) scored.push({ e, score, name });
        }
        scored.sort((a, b) => a.score - b.score || a.name.localeCompare(b.name));
        return scored.map(s => s.e);
    }
    onFilteredChanged: list.currentIndex = 0

    function cycle(dir) {
        const n = root.filtered.length;
        if (n === 0) return;
        list.currentIndex = ((list.currentIndex + dir) % n + n) % n;
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Theme.surface
        border.color: Theme.barBorder
        border.width: 1
    }

    Rectangle {
        id: fieldBox
        x: 14; y: 14
        width: parent.width - 28
        height: 42
        radius: 10
        color: Theme.surfaceHigh

        Text {
            id: prompt
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            text: "󰍉"
            color: Theme.fgMuted
            font.family: Config.font
            font.pixelSize: 15
        }

        TextInput {
            id: field
            anchors.left: prompt.right
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.fg
            font.family: Config.font
            font.pixelSize: 14
            clip: true
            focus: root.open

            Keys.onEscapePressed: root.close()
            Keys.onReturnPressed: root.launch(root.filtered[list.currentIndex])
            Keys.onDownPressed: list.currentIndex =
                Math.min(list.currentIndex + 1, root.filtered.length - 1)
            Keys.onUpPressed: list.currentIndex =
                Math.max(list.currentIndex - 1, 0)
            Keys.onTabPressed: root.cycle(1)
            Keys.onBacktabPressed: root.cycle(-1)

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: field.text === ""
                text: "launch…"
                color: Theme.fgMuted
                font.family: Config.font
                font.pixelSize: 14
            }
        }
    }

    ListView {
        id: list
        anchors.top: fieldBox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 14
        anchors.topMargin: 10
        clip: true
        spacing: 2

        model: root.filtered
        highlightMoveDuration: 60

        delegate: Rectangle {
            required property var modelData
            required property int index
            width: ListView.view.width
            height: 40
            radius: 8
            color: ListView.isCurrentItem ? Theme.surfaceHigh
                 : rowHover.containsMouse ? Qt.rgba(1, 1, 1, 0.03) : "transparent"

            Row {
                x: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Image {
                    width: 20; height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                    asynchronous: true
                    visible: status === Image.Ready
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.name
                    color: Theme.fg
                    font.family: Config.font
                    font.pixelSize: 13
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.comment ?? ""
                    color: Theme.fgMuted
                    font.family: Config.font
                    font.pixelSize: 10
                    visible: text !== ""
                }
            }

            MouseArea {
                id: rowHover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.launch(parent.modelData)
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.filtered.length === 0
            text: "no matches"
            color: Theme.fgMuted
            font.family: Config.font
            font.pixelSize: 12
        }
    }
}
