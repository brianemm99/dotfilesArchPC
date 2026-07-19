pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property bool panelOpen: false
    property int unread: 0

    readonly property var list: server.trackedNotifications

    // ── toast stack: ListModel so the Repeater updates incrementally
    // instead of rebuilding every card on each change ──
    property ListModel toastModel: ListModel {}
    property int seq: 0
    readonly property int maxToasts: 3

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: (n) => {
            n.tracked = true;
            root.unread += 1;
            if (!root.panelOpen) {
                root.toastModel.insert(0, {
                    seq: root.seq++,
                    appName: n.appName ?? "",
                    summary: n.summary ?? "",
                    body: n.body ?? ""
                });
                while (root.toastModel.count > root.maxToasts)
                    root.toastModel.remove(root.toastModel.count - 1);
            }
        }
    }

    function removeToast(seq) {
        for (let i = 0; i < toastModel.count; i++) {
            if (toastModel.get(i).seq === seq) { toastModel.remove(i); return; }
        }
    }

    function clearToasts() { toastModel.clear() }

    function openCenter() {
        clearToasts();
        panelOpen = true;
    }

    onPanelOpenChanged: {
        if (panelOpen) { unread = 0; clearToasts(); }
    }
}
