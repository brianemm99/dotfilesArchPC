pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
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

    // ── roll-out machinery ──
    // 0 = fully off-screen right, 1 = fully out. The window stays mapped
    // through the whole animation and unmaps only once fully retracted.
    property real slide: Notifs.panelOpen ? 1 : 0
    Behavior on slide {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }
    visible: slide > 0.001

    WlrLayershell.namespace: "quickshell:notifs"
    anchors { right: true }
    exclusiveZone: 0

    readonly property real fil: Config.tabFillet

    implicitWidth: 380
    implicitHeight: 672 + fil * 2
    color: "transparent"

    Item {
        id: slider
        width: parent.width
        height: parent.height
        x: (1 - root.slide) * root.width

        EdgePanelSurface { anchors.fill: parent }

        Text {
            id: header
            x: 18
            y: root.fil + 14
            text: `Notifications${Notifs.list.values.length > 0 ? ` — ${Notifs.list.values.length}` : ""}`
            color: Theme.fg
            font.family: Config.font
            font.pixelSize: 13
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 18
            y: root.fil + 14
            text: "clear"
            color: clearHover.containsMouse ? Theme.fg : Theme.fgMuted
            font.family: Config.font
            font.pixelSize: 11
            visible: Notifs.list.values.length > 0
            MouseArea {
                id: clearHover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    const all = [...Notifs.list.values];
                    for (const n of all) n.dismiss();
                }
            }
        }

        ListView {
            anchors.fill: parent
            anchors.topMargin: root.fil + 44
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.bottomMargin: root.fil + 12
            clip: true
            spacing: 8

            model: Notifs.list

            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: content.implicitHeight + 20
                radius: 8
                color: Theme.surfaceHigh

                Column {
                    id: content
                    x: 12; y: 10
                    width: parent.width - 40
                    spacing: 3

                    Text {
                        width: parent.width
                        text: modelData.appName || "notification"
                        color: Theme.fgMuted
                        font.family: Config.font
                        font.pixelSize: 9
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: modelData.summary
                        color: Theme.fg
                        font.family: Config.font
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }
                    Text {
                        width: parent.width
                        text: modelData.body
                        visible: (modelData.body ?? "") !== ""
                        color: Theme.fgMuted
                        font.family: Config.font
                        font.pixelSize: 10
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }

                Text {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 8
                    text: "✕"
                    color: xHover.containsMouse ? Theme.fg : Theme.fgMuted
                    font.pixelSize: 10
                    MouseArea {
                        id: xHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: parent.parent.modelData.dismiss()
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: Notifs.list.values.length === 0
                text: "nothing here"
                color: Theme.fgMuted
                font.family: Config.font
                font.pixelSize: 11
            }
        }
    }
}
