import QtQuick
import qs.Config
import qs.Services

Item {
    id: root

    property real tabWidth: Config.tabWidth
    property real panelWidth: tabWidth
    property string panelAlign: "center"

    property real expandedDrop: Config.tabDropHover
    property bool hoverOpens: true
    property bool pinned: false

    readonly property alias hovered: hover.containsMouse

    property real drop: pinned ? expandedDrop
                      : (hoverOpens && hover.containsMouse) ? expandedDrop
                      : Config.tabDrop
    Behavior on drop {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    readonly property real reveal: expandedDrop > 0 ? drop / expandedDrop : 0

    readonly property real bumpWidth: tabWidth + (panelWidth - tabWidth) * reveal
    readonly property real bumpX: panelAlign === "right" ? tabWidth - bumpWidth
                                : panelAlign === "left"  ? 0
                                : (tabWidth - bumpWidth) / 2

    implicitWidth: tabWidth
    implicitHeight: Config.barHeight + expandedDrop

    signal barClicked()

    // Super+Esc unpins every tab
    Connections {
        target: Panels
        function onDismissAll() { root.pinned = false }
    }

    MouseArea {
        id: hover
        x: Math.min(0, root.panelAlign === "right" ? root.tabWidth - root.panelWidth
                     : root.panelAlign === "left" ? 0
                     : (root.tabWidth - root.panelWidth) / 2)
        width: Math.max(root.tabWidth, root.panelWidth)
        height: root.implicitHeight
        hoverEnabled: true
        onClicked: (m) => { if (m.y < Config.barHeight) root.barClicked() }
    }
}
