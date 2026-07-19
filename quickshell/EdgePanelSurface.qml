import QtQuick
import QtQuick.Shapes
import qs.Theme
import qs.Config

// Right-edge panel silhouette: body flush to the screen edge, concave
// fillet flares top and bottom curving back into the edge, convex
// rounded corners on the left side. Fill the window with it; content
// belongs between y = fillet and y = height - fillet.
Shape {
    id: root

    property real fillet: Config.tabFillet
    property real cornerRadius: Config.tabRadius

    preferredRendererType: Shape.CurveRenderer

    function buildPath() {
        const W = width, H = height, f = fillet, r = cornerRadius;
        const fmt = (v) => v.toFixed(2);
        return `M ${fmt(W)} 0`
             + ` A ${fmt(f)} ${fmt(f)} 0 0 1 ${fmt(W - f)} ${fmt(f)}`     // top fillet: edge → body top
             + ` L ${fmt(r)} ${fmt(f)}`                                    // body top, leftward
             + ` A ${fmt(r)} ${fmt(r)} 0 0 0 0 ${fmt(f + r)}`              // top-left corner
             + ` L 0 ${fmt(H - f - r)}`                                    // left side, down
             + ` A ${fmt(r)} ${fmt(r)} 0 0 0 ${fmt(r)} ${fmt(H - f)}`      // bottom-left corner
             + ` L ${fmt(W - f)} ${fmt(H - f)}`                            // body bottom, rightward
             + ` A ${fmt(f)} ${fmt(f)} 0 0 1 ${fmt(W)} ${fmt(H)}`          // bottom fillet: body → edge
             + ` Z`;                                                       // closes up the screen edge
    }

    ShapePath {
        fillColor: Theme.surface
        strokeColor: Theme.barBorder
        strokeWidth: Config.borderWidth
        PathSvg { path: root.buildPath() }
    }
}
