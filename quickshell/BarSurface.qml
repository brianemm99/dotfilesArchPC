import QtQuick
import QtQuick.Shapes
import qs.Theme
import qs.Config

Shape {
    id: root
    property bool drawTab: true
    property real tabDrop: Config.tabDrop

    preferredRendererType: Shape.CurveRenderer

    // When drawTab is false these go to zero and the tab flattens
    // into a straight bottom edge (the lean bar's case).
    readonly property real effFillet: drawTab ? Config.tabFillet : 0
    readonly property real effRadius: drawTab ? Config.tabRadius : 0
    readonly property real effDrop:   drawTab ? tabDrop : 0

    readonly property real tabLeft:   (width - Config.tabWidth) / 2
    readonly property real tabRight:  (width + Config.tabWidth) / 2
    readonly property real tabBottom: Config.barHeight + effDrop

    ShapePath {
        fillColor: Theme.barBg
        strokeColor: Theme.barBorder
        strokeWidth: Config.borderWidth

        startX: 0; startY: 0
        PathLine { x: root.width; y: 0 }
        PathLine { x: root.width; y: Config.barHeight }

        // right shoulder: concave fillet into the tab
        PathLine { x: root.tabRight + root.effFillet; y: Config.barHeight }
        PathArc {
            x: root.tabRight
            y: Config.barHeight + root.effFillet
            radiusX: root.effFillet; radiusY: root.effFillet
            direction: PathArc.Counterclockwise
        }

        // down the right side, round the bottom-right corner
        PathLine { x: root.tabRight; y: root.tabBottom - root.effRadius }
        PathArc {
            x: root.tabRight - root.effRadius
            y: root.tabBottom
            radiusX: root.effRadius; radiusY: root.effRadius
            direction: PathArc.Clockwise
        }

        // across the bottom, round the bottom-left corner
        PathLine { x: root.tabLeft + root.effRadius; y: root.tabBottom }
        PathArc {
            x: root.tabLeft
            y: root.tabBottom - root.effRadius
            radiusX: root.effRadius; radiusY: root.effRadius
            direction: PathArc.Clockwise
        }

        // up the left side, concave fillet back into the bar
        PathLine { x: root.tabLeft; y: Config.barHeight + root.effFillet }
        PathArc {
            x: root.tabLeft - root.effFillet
            y: Config.barHeight
            radiusX: root.effFillet; radiusY: root.effFillet
            direction: PathArc.Counterclockwise
        }

        PathLine { x: 0; y: Config.barHeight }
        PathLine { x: 0; y: 0 }
    }
}
