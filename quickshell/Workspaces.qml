pragma ComponentBehavior: Bound
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Config

RowLayout {
    id: root
    required property var screen
    spacing: 6

    readonly property var monitor: Hyprland.monitorFor(root.screen)
    readonly property int persistCount: 5

    // Slots 1..5 always; higher ids appended only if they exist on this
    // monitor (Hyprland only reports existing workspaces, so persistence
    // is synthesized here).
    readonly property var slots: {
        const out = [];
        for (let i = 1; i <= persistCount; i++) out.push(i);
        for (const ws of Hyprland.workspaces.values) {
            if (ws.id > persistCount && ws.monitor === root.monitor)
                out.push(ws.id);
        }
        return out;
    }

    Repeater {
        model: root.slots

        Item {
            id: slot
            required property int modelData

            readonly property var ws:
                Hyprland.workspaces.values.find(w => w.id === slot.modelData) ?? null
            readonly property bool active:
                slot.modelData === root.monitor?.activeWorkspace?.id
            readonly property bool occupied:
                (slot.ws?.lastIpcObject?.windows ?? 0) > 0

            // Persistent slots always visible on every bar; dynamic (>5)
            // slots only on their own monitor (enforced at model build).
            // A persistent slot whose workspace lives on the OTHER monitor
            // still shows here as its state — by design; flag if unwanted.
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14

            // empty: small muted dot
            Rectangle {
                anchors.centerIn: parent
                width: 5; height: 5; radius: 2.5
                color: Theme.surfaceHigh
                visible: !slot.active && !slot.occupied
            }

            // occupied, inactive: large hollow ring
            Rectangle {
                anchors.centerIn: parent
                width: 12; height: 12; radius: 6
                color: "transparent"
                border.color: Theme.fgMuted
                border.width: 1.5
                visible: !slot.active && slot.occupied
            }

            // active: large filled circle
            Rectangle {
                anchors.centerIn: parent
                width: 12; height: 12; radius: 6
                color: Theme.primary
                visible: slot.active

                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${slot.modelData} })`)
            }
        }
    }
}
