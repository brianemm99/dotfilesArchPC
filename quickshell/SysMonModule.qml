import QtQuick
import QtQuick.Layouts
import qs.Theme
import qs.Config
import qs.Services

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Config.barHeight

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Ring {
            visible: SysMon.hasGpu
            pct: SysMon.gpuPct
            Layout.alignment: Qt.AlignVCenter
        }
        Ring {
            pct: SysMon.cpuPct
            Layout.alignment: Qt.AlignVCenter
        }
        Ring {
            pct: SysMon.memPct
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // whole cluster = one hover target
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: Panels.sysmonRingsHover = true
        onExited: Panels.sysmonRingsHover = false
    }
}
