import QtQuick
import QtQuick.Shapes
import qs.Theme
import qs.Config

// Edge panel silhouette. Default: body flush to the RIGHT screen edge.
// mirrored: true → flush to the LEFT edge (same shape, reflected).
Shape {
    id: root

    property real fillet: Config.tabFillet
    property real cornerRadius: Config.tabRadius
    property bool mirrored: false

    preferredRendererType: Shape.CurveRenderer

    function buildPath() {
        const W = width, H = height, f = fillet, r = cornerRadius;
        const fmt = (v) => v.toFixed(2);

        if (!mirrored) {
            return `M ${fmt(W)} 0`
                 + ` A ${fmt(f)} ${fmt(f)} 0 0 1 ${fmt(W - f)} ${fmt(f)}`
                 + ` L ${fmt(r)} ${fmt(f)}`
                 + ` A ${fmt(r)} ${fmt(r)} 0 0 0 0 ${fmt(f + r)}`
                 + ` L 0 ${fmt(H - f - r)}`
                 + ` A ${fmt(r)} ${fmt(r)} 0 0 0 ${fmt(r)} ${fmt(H - f)}`
                 + ` L ${fmt(W - f)} ${fmt(H - f)}`
                 + ` A ${fmt(f)} ${fmt(f)} 0 0 1 ${fmt(W)} ${fmt(H)}`
                 + ` Z`;
        }

        // reflected across x → W - x (sweep flags invert)
        return `M 0 0`
             + ` A ${fmt(f)} ${fmt(f)} 0 0 0 ${fmt(f)} ${fmt(f)}`
             + ` L ${fmt(W - r)} ${fmt(f)}`
             + ` A ${fmt(r)} ${fmt(r)} 0 0 1 ${fmt(W)} ${fmt(f + r)}`
             + ` L ${fmt(W)} ${fmt(H - f - r)}`
             + ` A ${fmt(r)} ${fmt(r)} 0 0 1 ${fmt(W - r)} ${fmt(H - f)}`
             + ` L ${fmt(f)} ${fmt(H - f)}`
             + ` A ${fmt(f)} ${fmt(f)} 0 0 0 0 ${fmt(H)}`
             + ` Z`;
    }

    ShapePath {
        fillColor: Theme.surface
        strokeColor: Theme.barBorder
        strokeWidth: Config.borderWidth
        PathSvg { path: root.buildPath() }
    }
}
