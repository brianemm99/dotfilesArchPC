import QtQuick
import QtQuick.Shapes
import qs.Theme

// Continuous mirrored waveform. Values 0..1, drawn as a filled curve
// reflected around the vertical center.
Shape {
    id: root

    property var values: []
    property color waveColor: Theme.primary
    property real fillOpacity: 0.22

    preferredRendererType: Shape.CurveRenderer

    // smoothed copy so frames don't strobe
    property var shown: []
    Timer {
        interval: 33
        repeat: true
        running: root.visible
        onTriggered: {
            const v = root.values;
            if (!v || v.length === 0) return;
            const s = (root.shown && root.shown.length === v.length)
                ? root.shown : new Array(v.length).fill(0);
            const out = [];
            for (let i = 0; i < v.length; i++)
                out.push(s[i] + (v[i] - s[i]) * 0.35);   // ease toward target
            root.shown = out;
        }
    }

    function buildPath() {
        const v = shown;
        const n = v ? v.length : 0;
        if (n < 2 || width <= 0) return "M 0 0";

        const W = width, H = height, mid = H / 2;
        const step = W / (n - 1);
        const fmt = (x) => x.toFixed(2);

        // top edge, smoothed with quadratic segments through midpoints
        let d = `M 0 ${fmt(mid - v[0] * mid)}`;
        for (let i = 1; i < n; i++) {
            const x0 = (i - 1) * step, x1 = i * step;
            const y0 = mid - v[i - 1] * mid, y1 = mid - v[i] * mid;
            const mx = (x0 + x1) / 2;
            d += ` Q ${fmt(x0)} ${fmt(y0)} ${fmt(mx)} ${fmt((y0 + y1) / 2)}`;
            d += ` Q ${fmt(x1)} ${fmt(y1)} ${fmt(x1)} ${fmt(y1)}`;
        }

        // mirrored bottom edge, right to left
        d += ` L ${fmt(W)} ${fmt(mid + v[n - 1] * mid)}`;
        for (let i = n - 2; i >= 0; i--) {
            const x0 = (i + 1) * step, x1 = i * step;
            const y0 = mid + v[i + 1] * mid, y1 = mid + v[i] * mid;
            const mx = (x0 + x1) / 2;
            d += ` Q ${fmt(x0)} ${fmt(y0)} ${fmt(mx)} ${fmt((y0 + y1) / 2)}`;
            d += ` Q ${fmt(x1)} ${fmt(y1)} ${fmt(x1)} ${fmt(y1)}`;
        }

        return d + " Z";
    }

    ShapePath {
        fillColor: Qt.rgba(root.waveColor.r, root.waveColor.g,
                           root.waveColor.b, root.fillOpacity)
        strokeColor: Qt.rgba(root.waveColor.r, root.waveColor.g,
                             root.waveColor.b, root.fillOpacity * 1.8)
        strokeWidth: 1
        PathSvg { path: root.buildPath() }
    }
}
