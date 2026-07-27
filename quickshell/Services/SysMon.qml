pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpuPct: 0
    property real gpuPct: 0
    property real memPct: 0

    property real memUsed: 0
    property real memTotal: 0
    property real vramUsed: 0
    property real vramTotal: 0

    property real cpuTemp: 0
    property real load1: 0
    property int  cores: 0
    property bool hasGpu: false

    property real prevBusy: -1
    property real prevTotal: -1

    function fmtBytes(b) {
        if (b <= 0) return "0";
        const gb = b / (1024 * 1024 * 1024);
        if (gb >= 1) return gb.toFixed(1) + " GiB";
        return (b / (1024 * 1024)).toFixed(0) + " MiB";
    }

    Process {
        id: sample
        command: ["/bin/sh", "-c", "$HOME/.local/bin/sysmon"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                for (const ln of lines) {
                    const p = ln.trim().split(/\s+/);
                    if (p[0] === "cpu") {
                        const busy = Number(p[1]), total = Number(p[2]);
                        if (root.prevTotal >= 0 && total > root.prevTotal) {
                            root.cpuPct = Math.max(0, Math.min(1,
                                (busy - root.prevBusy) / (total - root.prevTotal)));
                        }
                        root.prevBusy = busy;
                        root.prevTotal = total;
                    } else if (p[0] === "mem") {
                        root.memUsed = Number(p[1]);
                        root.memTotal = Number(p[2]);
                        root.memPct = root.memTotal > 0 ? root.memUsed / root.memTotal : 0;
                    } else if (p[0] === "gpu") {
                        root.hasGpu = true;
                        root.gpuPct = Math.max(0, Math.min(1, Number(p[1]) / 100));
                        root.vramUsed = Number(p[2]);
                        root.vramTotal = Number(p[3]);
                    } else if (p[0] === "temp") {
                        root.cpuTemp = Number(p[1]) / 1000;
                    } else if (p[0] === "load") {
                        root.load1 = Number(p[1]);
                        root.cores = Number(p[2]);
                    }
                }
            }
        }
    }

    Timer {
        interval: 1500
        repeat: true
        triggeredOnStart: true
        running: true
        onTriggered: sample.running = true
    }
}
