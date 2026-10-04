import QtQuick
import Quickshell
import qs.config
import qs.widgets
import qs.services
import "services"
import "components"

PxPage {
    id: page
    heading: "Community Plugins"
    subtitle: "Discover plugins published by the AngelOS community."
    property string search: ""
    property string category: "All"
    property var selected: null
    property var selectedInstalled: null
    property string registryInput: Registry.url
    property var plugin

    Component.onCompleted: {
        Registry.plugin = plugin
        Registry.url = plugin.get("registryUrl", Registry.defaultUrl)
        Registry.fetch()
    }

    function matches(entry) {
        const q = search.trim().toLowerCase()
        const hay = [entry.name, entry.author, entry.description, ...(entry.tags || [])].join(" ").toLowerCase()
        return (!q || hay.includes(q)) && (category === "All" || (entry.tags || []).map(t => String(t).toLowerCase()).includes(category.toLowerCase()))
    }

    PxField {
        width: parent.width
        placeholder: "Search plugins by name, author, description or tag"
        text: page.search
        onEdited: page.search = text
    }

    PxGroup {
        width: parent.width
        title: "Installed plugins (" + Plugins.plugins.length + ")"
        icon: "plug"
        Repeater {
            model: Plugins.plugins
            InstalledPluginCard {
                entry: modelData
                onShowDetails: entry => page.selectedInstalled = entry
            }
        }
        PxText { visible: Plugins.scanning; text: "Reading installed plugins…"; dim: true }
    }
    Row {
        spacing: Theme.u * 2
        Repeater {
            model: ["All", "Widgets", "Desktop", "Bar", "Utilities", "Themes"]
            PxButton { compact: true; text: modelData; checked: page.category === modelData; onClicked: page.category = modelData }
        }
    }

    PxGroup {
        visible: !!page.selectedInstalled
        width: parent.width
        title: page.selectedInstalled ? I18n.label(page.selectedInstalled.name) : "Installed plugin details"
        PxText {
            width: parent.width
            text: page.selectedInstalled ? I18n.label(page.selectedInstalled.description || "") +
                "\n\nID: " + page.selectedInstalled.id +
                "\nVersion: " + (page.selectedInstalled.version || "0") +
                "\nAuthor: " + (page.selectedInstalled.author || "Unknown") +
                "\nLocation: " + page.selectedInstalled.dir : ""
            wrapMode: Text.Wrap
        }
        PxButton { compact: true; icon: "folder"; text: "Open folder"; onClicked: Shell.openPath(page.selectedInstalled.dir) }
        PxButton { compact: true; icon: "close"; text: "Close"; onClicked: page.selectedInstalled = null }
    }

    PxGroup {
        width: parent.width
        title: "Updates"
        icon: "download"
        PxText {
            width: parent.width
            text: Registry.availablePluginUpdates + " plugin update" + (Registry.availablePluginUpdates === 1 ? "" : "s") + " available"
            dim: true
        }
        Row {
            spacing: Theme.u * 2
            PxButton {
                compact: true
                text: Registry.busy && Registry.batchTotal > 0 ? "Updating " + Registry.batchDone + "/" + Registry.batchTotal : "Update all plugins"
                icon: "download"
                enabled: !Registry.busy && Registry.availablePluginUpdates > 0
                onClicked: Registry.updateAllPlugins()
            }
            PxButton {
                compact: true
                text: Registry.storeUpdateAvailable ? "Update Store to v" + Registry.storeEntry.version : "Store is up to date"
                icon: Registry.storeUpdateAvailable ? "refresh" : "check"
                enabled: !Registry.busy && Registry.storeUpdateAvailable
                onClicked: Registry.install(Registry.storeEntry)
            }
        }
        PxText {
            visible: Registry.batchTotal > 0 && !Registry.busy
            width: parent.width
            text: "Updated " + Registry.batchDone + "/" + Registry.batchTotal + (Registry.batchFailed ? " · " + Registry.batchFailed + " failed" : " · all complete")
            dim: Registry.batchFailed > 0
        }
    }

    PxGroup {
        width: parent.width
        title: "Available plugins (" + Registry.entries.filter(page.matches).length + ")"
        icon: "package"
        Repeater {
            model: Registry.entries.filter(page.matches)
            PluginCard { entry: modelData; onOpenDetails: entry => page.selected = entry }
        }
        PxText { visible: !Registry.busy && Registry.entries.filter(page.matches).length === 0; text: "No plugins match this search."; dim: true }
    }

    PxGroup {
        width: parent.width
        title: "Registry"
        icon: "settings"
        PxText {
            width: parent.width
            text: Registry.status === "loading" ? "Loading registry…" : Registry.error || (Registry.entries.length + " approved plugins loaded")
            dim: true
            wrapMode: Text.Wrap
        }
        PxText {
            width: parent.width
            text: "Only plugins marked approved in the registry are listed. Review submissions and change their status in the registry repository."
            dim: true
            wrapMode: Text.Wrap
        }
        Row {
            spacing: Theme.u * 2
            PxButton { compact: true; text: "Refresh"; icon: "refresh"; enabled: !Registry.busy; onClicked: Registry.fetch() }
            PxButton { compact: true; text: "Save registry URL"; icon: "save"; onClicked: Registry.setRegistry(page.registryInput) }
            PxButton { compact: true; text: "Moderate on GitHub"; icon: "external"; onClicked: Quickshell.execDetached(["xdg-open", "https://github.com/futureUnd1ground/angelos-community-registry"]) }
        }
        PxField { width: parent.width; text: page.registryInput; onEdited: page.registryInput = text; placeholder: "HTTPS plugins.json URL" }
    }

    PxGroup {
        visible: !!page.selected
        width: parent.width
        title: page.selected ? page.selected.name : "Plugin details"
        PxText {
            width: parent.width
            text: page.selected ? ((page.selected.description || "") +
                "\n\nby " + (page.selected.author || "Unknown") +
                "\nLatest version: " + (page.selected.version || "0") +
                (Registry.installed(page.selected.id) ? "\nInstalled version: " + Registry.version(page.selected.id) : "\nNot installed") +
                "\nMinimum AngelOS: " + (page.selected.minAngelOSVersion || "Not specified") +
                "\nTags: " + (page.selected.tags || []).join(", ") +
                "\nDependencies: " + (page.selected.dependencies || []).join(", ") +
                "\nPermissions: " + (page.selected.permissions || []).join(", ") +
                "\nLicense: " + (page.selected.license || "Not specified") +
                (page.selected.homepage ? "\nHomepage: " + page.selected.homepage : "") +
                (page.selected.changelog ? "\nChangelog: " + page.selected.changelog : "")) : ""
            wrapMode: Text.Wrap
        }
        Repeater {
            model: page.selected ? (page.selected.screenshots || []) : []
            PxText { width: parent.width; text: "Screenshot: " + modelData; wrapMode: Text.Wrap; dim: true }
        }
        PxButton {
            compact: true
            text: Registry.installed(page.selected ? page.selected.id : "") ? "Remove plugin" : "Install plugin"
            icon: Registry.installed(page.selected ? page.selected.id : "") ? "trash" : "download"
            visible: !!page.selected
            enabled: !Registry.busy
            onClicked: Registry.installed(page.selected.id) ? Registry.uninstall(page.selected.id) : Registry.install(page.selected)
        }
        PxButton { compact: true; text: "Open repository"; icon: "external"; visible: !!(page.selected && page.selected.repository); onClicked: Quickshell.execDetached(["xdg-open", page.selected.repository]) }
        PxButton { compact: true; text: "Close"; icon: "close"; onClicked: page.selected = null }
    }
}
