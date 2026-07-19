import QtQuick
import qs.Config

// Base for anything living as a tab on the bar's bottom edge.
Item {
    id: root

    // Footprint in the bar (the "face").
    property real tabWidth: Config.tabWidth

    // Open-panel width — may exceed the face. The shape's bump grows
    // from tabWidth to panelWidth as the tab opens.
    property real panelWidth: tabWidth

    // How the wide panel aligns to the face: "center", "left", "right".
    // A right-edge tab uses "right" so the panel grows leftward.
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

    // Current bump geometry, slot-local. BarSurface reads these.
    readonly property real bumpWidth: tabWidth + (panelWidth - tabWidth) * reveal
    readonly property real bumpX: panelAlign === "right" ? tabWidth - bumpWidth
                                : panelAlign === "left"  ? 0
                                : (tabWidth - bumpWidth) / 2

    implicitWidth: tabWidth
    implicitHeight: Config.barHeight + expandedDrop

    signal barClicked()

    MouseArea {
        id: hover
        // Cover face plus wherever the panel extends.
        x: Math.min(0, root.panelAlign === "right" ? root.tabWidth - root.panelWidth
                     : root.panelAlign === "left" ? 0
                     : (root.tabWidth - root.panelWidth) / 2)
        width: Math.max(root.tabWidth, root.panelWidth)
        height: root.implicitHeight
        hoverEnabled: true
        onClicked: (m) => { if (m.y < Config.barHeight) root.barClicked() }
    }
}
