import QtQuick
import qs.config
import qs.widgets
import qs.services

PxBox {
    id: card
    required property var entry
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
        PxIcon { name: card.entry && card.entry.icon || "package"; pixel: Theme.u * 3 }
        Column {
            id: cardColumn
            width: parent.width - 110
            spacing: Theme.u
            PxText { text: card.entry ? card.entry.name : ""; font.bold: true }
            PxText { text: card.entry ? "by " + (card.entry.author || "Unknown") + "  ·  v" + (card.entry.version || "0") : ""; kind: "tiny"; dim: true }
            PxText { width: parent.width; text: card.entry ? card.entry.description || "" : ""; wrapMode: Text.Wrap; dim: true }
            PxText { text: card.entry ? (card.entry.tags || []).join("  ·  ") : ""; kind: "tiny"; dim: true; visible: !!card.entry && (card.entry.tags || []).length > 0 }
        }
        Column {
            id: cardSide
            spacing: Theme.u * 2
            PxButton {
                compact: true
                text: card.entry ? (Registry.installed(card.entry.id) ? (Registry.newer(Registry.version(card.entry.id), card.entry.version) ? "Update" : "Installed") : "Install") : "Install"
                icon: card.entry && Registry.installed(card.entry.id) ? "check" : "download"
                enabled: !!card.entry && !Registry.busy && (!Registry.installed(card.entry.id) || Registry.newer(Registry.version(card.entry.id), card.entry.version))
                onClicked: Registry.install(card.entry)
            }
            PxButton { visible: !!card.entry && !!Registry.installed(card.entry.id); compact: true; danger: true; text: card.confirmingRemove ? "Confirm" : "Remove"; icon: "trash"; enabled: !Registry.busy; onClicked: { if (!card.confirmingRemove) { card.confirmingRemove = true; return; } card.confirmingRemove = false; Registry.uninstall(card.entry.id); } }
            PxButton { compact: true; text: "Details"; icon: "info"; enabled: !!card.entry; onClicked: card.openDetails(card.entry) }
        }
    }
}
