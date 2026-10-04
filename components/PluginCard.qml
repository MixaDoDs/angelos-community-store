import QtQuick
import qs.config
import qs.widgets
import qs.services
import "../services"

PxBox {
    id: card
    required property var entry
    property string query: ""
    property bool confirmingRemove: false
    signal openDetails(var entry)
    width: parent ? parent.width : 500
    height: cardColumn.implicitHeight + Theme.u * 8
    color: Theme.face

    Row {
        x: Theme.u * 4
        y: Theme.u * 4
        width: parent.width - Theme.u * 8
        spacing: Theme.u * 4

        PxIcon { name: card.entry.icon || "package"; pixel: Theme.u * 3 }
        Column {
            id: cardColumn
            width: parent.width - 110
            spacing: Theme.u
            PxText { text: card.entry.name; font.bold: true }
            PxText { text: "by " + (card.entry.author || "Unknown") + "  ·  v" + (card.entry.version || "0"); kind: "tiny"; dim: true }
            PxText { width: parent.width; text: card.entry.description || ""; wrapMode: Text.Wrap; dim: true }
            PxText { text: (card.entry.tags || []).join("  ·  "); kind: "tiny"; dim: true; visible: (card.entry.tags || []).length > 0 }
        }
        Column {
            id: cardSide
            spacing: Theme.u * 2
            PxButton {
                compact: true
                text: Registry.installed(card.entry.id) ? (Registry.newer(Registry.version(card.entry.id), card.entry.version) ? "Update" : "Installed") : "Install"
                icon: Registry.installed(card.entry.id) ? (Registry.newer(Registry.version(card.entry.id), card.entry.version) ? "download" : "check") : "download"
                enabled: !Registry.busy && (!Registry.installed(card.entry.id) || Registry.newer(Registry.version(card.entry.id), card.entry.version))
                onClicked: Registry.install(card.entry)
            }
            PxButton {
                visible: !!Registry.installed(card.entry.id)
                compact: true
                danger: true
                text: card.confirmingRemove ? "Confirm" : "Remove"
                icon: "trash"
                enabled: !Registry.busy
                onClicked: {
                    if (!card.confirmingRemove) {
                        card.confirmingRemove = true
                        return
                    }
                    card.confirmingRemove = false
                    Registry.uninstall(card.entry.id)
                }
            }
            PxButton { compact: true; text: "Details"; icon: "info"; onClicked: card.openDetails(card.entry) }
        }
    }
}
