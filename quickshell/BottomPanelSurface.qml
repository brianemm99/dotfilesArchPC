import QtQuick
import QtQuick.Shapes
import qs.Theme
import qs.Config

Shape {
    id: root

    property real fillet: Config.tabFillet
    property real cornerRadius: Config.tabRadius

    preferredRendererType: Shape.CurveRenderer

    function buildPath() {
        const W = width, H = height, f = fillet, r = cornerRadius;
        const fmt = (v) => v.toFixed(2);
        return `M 0 ${fmt(H)}`
             + ` A ${fmt(f)} ${fmt(f)} 0 0 0 ${fmt(f)} ${fmt(H - f)}`      // left flare into body side
             + ` L ${fmt(f)} ${fmt(r)}`                                     // up the left side
             + ` A ${fmt(r)} ${fmt(r)} 0 0 1 ${fmt(f + r)} 0`               // top-left corner
             + ` L ${fmt(W - f - r)} 0`                                     // across the top
             + ` A ${fmt(r)} ${fmt(r)} 0 0 1 ${fmt(W - f)} ${fmt(r)}`       // top-right corner
             + ` L ${fmt(W - f)} ${fmt(H - f)}`                             // down the right side
             + ` A ${fmt(f)} ${fmt(f)} 0 0 0 ${fmt(W)} ${fmt(H)}`           // right flare back to edge
             + ` Z`;
    }

    ShapePath {
        fillColor: Theme.surface
        strokeColor: Theme.barBorder
        strokeWidth: Config.borderWidth
        PathSvg { path: root.buildPath() }
    }
}
