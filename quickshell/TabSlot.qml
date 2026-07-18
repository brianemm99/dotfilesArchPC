import QtQuick
import qs.Config

// Base for anything living as a tab on the bar's bottom edge.
Item {
    id: root

    property real tabWidth: Config.tabWidth
    property real expandedDrop: Config.tabDropHover

    // If false, hover does nothing — the tab opens only via `pinned`
    // (click/shortcut). Lets big panels stay out of the way, and lets
    // Bar.qml arm their mask region only while open.
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

    implicitWidth: tabWidth
    implicitHeight: Config.barHeight + expandedDrop

    signal barClicked()

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: (m) => { if (m.y < Config.barHeight) root.barClicked() }
    }
}
