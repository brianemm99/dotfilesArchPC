pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import Qt.labs.folderlistmodel
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

    property real slide: Panels.wallpaperOpen ? 1 : 0
    Behavior on slide {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }
    visible: slide > 0.001

    // Latch: once a choice is made, block every further preview so a
    // trailing currentIndex change can't overwrite the committed image.
    property bool committing: false
    onVisibleChanged: if (!visible) committing = false   // reset when fully closed

    WlrLayershell.namespace: "quickshell:wallpaperpicker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Panels.wallpaperOpen
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { bottom: true }
    exclusiveZone: 0

    readonly property real fil: Config.tabFillet

    implicitWidth: 960
    implicitHeight: 420 + fil
    color: "transparent"

    function bare(p) { return String(p).replace(/^file:\/\//, ""); }

    function pathAt(i) {
        if (i < 0 || i >= grid.count) return "";
        return bare(grid.model.get(i, "filePath"));
    }

    function applyImage(img) {
        if (img === "" || committing) return;   // latch blocks stray previews
        const s = Quickshell.screens;
        for (let i = 0; i < s.length; i++)
            Quickshell.execDetached(
                ["hyprctl", "hyprpaper", "wallpaper", `${s[i].name},${img}`]);
    }

    function commitIndex(i) {
        const img = pathAt(i);
        if (img === "") return;
        committing = true;              // no preview may fire after this
        previewDebounce.stop();
        // apply directly (bypasses the latch — this IS the authoritative set)
        const s = Quickshell.screens;
        for (let k = 0; k < s.length; k++)
            Quickshell.execDetached(
                ["hyprctl", "hyprpaper", "wallpaper", `${s[k].name},${img}`]);
        Quickshell.execDetached(["/bin/sh", "-c",
            "$HOME/.local/bin/wallpaper \"" + img + "\""]);
        Panels.wallpaperOpen = false;
    }

    function revertAndClose() {
        committing = true;
        previewDebounce.stop();
        Quickshell.execDetached(["/bin/sh", "-c", "$HOME/.local/bin/wallpaper-restore"]);
        Panels.wallpaperOpen = false;
    }

    Connections {
        target: Panels
        function onDismissAll() {
            if (Panels.wallpaperOpen) root.revertAndClose();
        }
    }

    Timer {
        id: previewDebounce
        interval: 120
        onTriggered: root.applyImage(root.pathAt(grid.currentIndex))
    }

    Item {
        id: slider
        width: parent.width
        height: parent.height
        y: (1 - root.slide) * parent.height

        BottomPanelSurface { anchors.fill: parent }

        Text {
            x: root.fil + 12
            y: 14
            text: "wallpaper"
            color: Theme.fgMuted
            font.family: Config.font
            font.pixelSize: 11
        }

        GridView {
            id: grid
            anchors.fill: parent
            anchors.topMargin: 40
            anchors.leftMargin: root.fil + 12
            anchors.rightMargin: root.fil + 12
            anchors.bottomMargin: 16
            clip: true

            cellWidth: 184
            cellHeight: 116

            focus: Panels.wallpaperOpen
            onVisibleChanged: if (visible) { root.committing = false; currentIndex = 0 }
            onCurrentIndexChanged: previewDebounce.restart()

            model: FolderListModel {
                id: folderModel
                folder: "file://" + Config.wallpaperDir
                nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
                showDirs: false
            }

            Keys.onPressed: (e) => {
                switch (e.key) {
                case Qt.Key_Escape:
                    root.revertAndClose(); e.accepted = true; break;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    root.commitIndex(grid.currentIndex); e.accepted = true; break;
                case Qt.Key_Tab:
                    grid.currentIndex = (grid.currentIndex + 1) % grid.count;
                    e.accepted = true; break;
                case Qt.Key_Backtab:
                    grid.currentIndex =
                        (grid.currentIndex - 1 + grid.count) % grid.count;
                    e.accepted = true; break;
                case Qt.Key_Left:  case Qt.Key_H:
                    grid.moveCurrentIndexLeft(); e.accepted = true; break;
                case Qt.Key_Right: case Qt.Key_L:
                    grid.moveCurrentIndexRight(); e.accepted = true; break;
                case Qt.Key_Down:  case Qt.Key_J:
                    grid.moveCurrentIndexDown(); e.accepted = true; break;
                case Qt.Key_Up:    case Qt.Key_K:
                    grid.moveCurrentIndexUp(); e.accepted = true; break;
                }
            }

            delegate: Item {
                id: cell
                required property string filePath
                required property int index

                width: grid.cellWidth
                height: grid.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 10
                    color: "transparent"
                    border.width: 2
                    border.color: cell.GridView.isCurrentItem
                        ? Theme.primary : "transparent"

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: 8
                        clip: true
                        color: Theme.surfaceHigh
                        Image {
                            anchors.fill: parent
                            source: "file://" + root.bare(cell.filePath)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 200
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: if (!root.committing) grid.currentIndex = cell.index
                    onClicked: root.commitIndex(cell.index)
                }
            }
        }
    }
}
