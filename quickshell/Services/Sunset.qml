pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // "auto" = follow hyprsunset.conf profiles; "warm"/"off" = manual override.
    property string mode: "auto"
    property bool running: false

    // matches the 19:00 profile in hyprsunset.conf
    readonly property int warmTemp: 2900

    Process {
        id: check
        command: ["/bin/sh", "-c", "pgrep -x hyprsunset >/dev/null && echo yes || echo no"]
        stdout: StdioCollector {
            onStreamFinished: root.running = text.trim() === "yes"
        }
    }
    Timer {
        interval: 5000
        repeat: true
        triggeredOnStart: true
        running: true
        onTriggered: check.running = true
    }

    function setWarm() {
        Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature",
                                 String(warmTemp)]);
        mode = "warm";
    }
    function setOff() {
        Quickshell.execDetached(["hyprctl", "hyprsunset", "identity"]);
        mode = "off";
    }
    // Hand control back to the schedule: hyprsunset re-evaluates profiles
    // on restart, so a clean restart is the reliable "auto" path.
    function setAuto() {
        Quickshell.execDetached(["/bin/sh", "-c",
            "pkill -x hyprsunset; sleep 0.3; hyprsunset >/dev/null 2>&1 &"]);
        mode = "auto";
    }

    function cycle() {
        if (mode === "auto") setWarm();
        else if (mode === "warm") setOff();
        else setAuto();
    }
}
