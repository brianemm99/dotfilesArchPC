pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Consumers set this true while they need the wave; cava only runs then.
    property bool active: false

    readonly property int bars: 48
    property var values: new Array(48).fill(0)   // 0..1

    Process {
        id: cava
        running: root.active
        command: ["/bin/sh", "-c",
                  "exec cava -p $HOME/.config/cava/qs-visualizer.conf"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (!line || line.length < 2) return;
                const parts = line.split(";");
                const out = [];
                for (let i = 0; i < parts.length; i++) {
                    const v = Number(parts[i]);
                    if (!isNaN(v)) out.push(Math.max(0, Math.min(1, v / 1000)));
                }
                if (out.length > 0) root.values = out;
            }
        }
    }

    onActiveChanged: if (!active) values = new Array(bars).fill(0)
}
