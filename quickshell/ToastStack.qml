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

    visible: Notifs.toastModel.count > 0

    WlrLayershell.namespace: "quickshell:toasts"
    WlrLayershell.layer: WlrLayer.Overlay
    anchors { top: true; right: true }
    margins.top: 6
    exclusiveZone: 0

    implicitWidth: 360
    implicitHeight: 3 * 96 + 2 * 8
    color: "transparent"

    mask: Region {
        x: 0; y: 0
        width: root.width
        height: col.childrenRect.height
    }

    Column {
        id: col
        anchors.right: parent.right
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.toastModel

            delegate: Item {
                id: card
                required property int seq
                required property string appName
                required property string summary
                required property string body

                width: col.width
                height: bodyCol.implicitHeight + 24

                property real slide: 0
                property bool leaving: false
                Component.onCompleted: slide = 1
                Behavior on slide {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }

                // slide out, THEN remove from the model
                function leave() {
                    if (leaving) return;
                    leaving = true;
                    slide = 0;
                    gone.start();
                }
                Timer {
                    id: gone
                    interval: 220
                    onTriggered: Notifs.removeToast(card.seq)
                }

                Timer {
                    interval: 6000
                    running: !cardHover.containsMouse && !card.leaving
                    onTriggered: card.leave()
                }

                Rectangle {
                    width: parent.width
                    height: parent.height
                    x: (1 - card.slide) * (root.width + 20)
                    radius: 10
                    color: Theme.surface
                    border.color: Theme.barBorder
                    border.width: 1

                    Column {
                        id: bodyCol
                        x: 14; y: 12
                        width: parent.width - 48
                        spacing: 3

                        Text {
                            width: parent.width
                            text: card.appName || "notification"
                            color: Theme.fgMuted
                            font.family: Config.font
                            font.pixelSize: 9
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: card.summary
                            color: Theme.fg
                            font.family: Config.font
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                        Text {
                            width: parent.width
                            text: card.body
                            visible: card.body !== ""
                            color: Theme.fgMuted
                            font.family: Config.font
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: cardHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Notifs.openCenter()
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        text: "✕"
                        color: xHover.containsMouse ? Theme.fg : Theme.fgMuted
                        font.pixelSize: 10
                        MouseArea {
                            id: xHover
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: card.leave()
                        }
                    }
                }
            }
        }
    }
}
