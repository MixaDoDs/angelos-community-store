import QtQuick
import Quickshell
import qs.config
import qs.widgets
import qs.services

PxBox {
    id: card
    required property var entry
    property bool confirmingRemove: false
    signal showDetails(var entry)
    width: parent ? parent.width : 500
    height: content.implicitHeight + Theme.u * 8
    color: Theme.face

    Row {
        id: content
        x: Theme.u * 4
        y: Theme.u * 4
        width: parent.width - Theme.u * 8
        spacing: Theme.u * 3
        PxIcon { name: card.entry && card.entry.icon || "plug"; pixel: Theme.u * 3 }
        Column {
            width: parent.width - actions.width - parent.spacing * 2
            spacing: Theme.u
            PxText { text: card.entry ? I18n.label(card.entry.name) + "  v" + (card.entry.version || "0") : ""; font.bold: true }
            PxText { width: parent.width; text: card.entry ? I18n.label(card.entry.description || "") : ""; wrapMode: Text.Wrap; dim: true }
            PxText { text: card.entry ? ((card.entry.bundled ? "Built-in" : "User plugin") + (card.entry.author ? " · " + card.entry.author : "")) : ""; kind: "tiny"; dim: true }
        }
        Column {
            id: actions
            spacing: Theme.u * 2
            PxToggle { checked: card.entry ? Plugins.isEnabled(card.entry) : false; onToggled: checked => { if (card.entry) Plugins.setEnabled(card.entry.id, checked); } }
            PxButton { compact: true; text: "Details"; icon: "info"; enabled: !!card.entry; onClicked: card.showDetails(card.entry) }
            PxButton {
                compact: true
                danger: true
                text: card.confirmingRemove ? "Confirm" : (card.entry && card.entry.bundled ? "Hide" : "Remove")
                icon: "trash"
                enabled: !!card.entry
                onClicked: {
                    if (!card.confirmingRemove) { card.confirmingRemove = true; return; }
                    card.confirmingRemove = false;
                    Plugins.remove(card.entry.id);
                    Plugins.reload();
                }
            }
            PxButton { compact: true; icon: "folder"; enabled: !!card.entry; onClicked: Shell.openPath(card.entry.dir) }
        }
    }
}
