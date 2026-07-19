import QtQuick
import QtQuick.Shapes
import qs.Theme
import qs.Config

Shape {
    id: root
    property var tabs: []

    preferredRendererType: Shape.CurveRenderer

    function buildPath() {
        const W = width, H = Config.barHeight;
        const fmt = (v) => v.toFixed(2);
        let d = `M 0 0 L ${fmt(W)} 0 L ${fmt(W)} ${fmt(H)}`;

        const list = tabs.slice().sort(
            (a, b) => (b.x + b.bumpX) - (a.x + a.bumpX));
        for (const t of list) {
            const rev = t.expandedDrop > 0
                ? Math.min(1, t.drop / t.expandedDrop) : 0;
            const f = Config.tabFillet * rev;
            const r = Config.tabRadius * rev;
            const L = t.x + t.bumpX, R = L + t.bumpWidth, B = H + t.drop;
            d += ` L ${fmt(R + f)} ${fmt(H)}`
               + ` A ${fmt(f)} ${fmt(f)} 0 0 0 ${fmt(R)} ${fmt(H + f)}`
               + ` L ${fmt(R)} ${fmt(B - r)}`
               + ` A ${fmt(r)} ${fmt(r)} 0 0 1 ${fmt(R - r)} ${fmt(B)}`
               + ` L ${fmt(L + r)} ${fmt(B)}`
               + ` A ${fmt(r)} ${fmt(r)} 0 0 1 ${fmt(L)} ${fmt(B - r)}`
               + ` L ${fmt(L)} ${fmt(H + f)}`
               + ` A ${fmt(f)} ${fmt(f)} 0 0 0 ${fmt(L - f)} ${fmt(H)}`;
        }

        d += ` L 0 ${fmt(H)} Z`;
        return d;
    }

    ShapePath {
        fillColor: Theme.barBg
        strokeColor: Theme.barBorder
        strokeWidth: Config.borderWidth
        PathSvg { path: root.buildPath() }
    }
}
