import QtQuick
import QtQuick.Shapes
import qs.Theme
import qs.Config

Item {
    id: root

    property real pct: 0                    // 0..1
    property real ringSize: 24
    property real stroke: 3
    property color arcColor: Theme.primary
    property int labelSize: 8
    property bool showLabel: true

    Behavior on pct {
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }

    implicitWidth: ringSize
    implicitHeight: ringSize

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // track
        ShapePath {
            strokeColor: Theme.surfaceHigh
            strokeWidth: root.stroke
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.ringSize / 2
                centerY: root.ringSize / 2
                radiusX: (root.ringSize - root.stroke) / 2
                radiusY: (root.ringSize - root.stroke) / 2
                startAngle: -90
                sweepAngle: 360
            }
        }

        // progress
        ShapePath {
            strokeColor: root.arcColor
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.ringSize / 2
                centerY: root.ringSize / 2
                radiusX: (root.ringSize - root.stroke) / 2
                radiusY: (root.ringSize - root.stroke) / 2
                startAngle: -90
                sweepAngle: 360 * root.pct
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.showLabel
        text: Math.round(root.pct * 100)
        color: Theme.fg
        font.family: Config.font
        font.pixelSize: root.labelSize
    }
}
