pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.services

Singleton {
    id: root
    property var plugin: null
    property string defaultUrl: "https://raw.githubusercontent.com/futureUnd1ground/angelos-community-registry/main/plugins.json"
    property string url: ""
    property var entries: []
    property string error: ""
    property string status: "idle"
    property bool busy: fetcher.running || installer.running
    signal changed
    signal operationFinished(bool ok, string message)

    Component.onCompleted: {
        if (!plugin)
            return
        url = plugin.get("registryUrl", defaultUrl)
        fetch()
    }

    function fetch() {
        if (fetcher.running)
            return
        error = ""
        status = "loading"
        fetcher.command = ["python3", plugin.dir + "/scripts/community-store.py", "fetch", url]
        fetcher.running = true
    }

    function install(entry) {
        if (!entry || installer.running)
            return
        error = ""
        status = "installing"
        installer.command = ["python3", plugin.dir + "/scripts/community-store.py", "install",
                             entry.source || "", entry.id || "", entry.version || ""]
        installer.running = true
    }

    function uninstall(id) {
        Plugins.remove(id)
        Plugins.reload()
        changed()
    }

    function installed(id) {
        return Plugins.byId(id)
    }

    function version(id) {
        const p = installed(id)
        return p ? String(p.version || "0") : ""
    }

    function newer(installedVersion, latestVersion) {
        const a = String(installedVersion || "0").split(".").map(Number)
        const b = String(latestVersion || "0").split(".").map(Number)
        for (let i = 0; i < Math.max(a.length, b.length); i++) {
            const x = Number.isFinite(a[i]) ? a[i] : 0
            const y = Number.isFinite(b[i]) ? b[i] : 0
            if (y !== x)
                return y > x
        }
        return false
    }

    function setRegistry(value) {
        const next = String(value || "").trim()
        if (!next || !next.startsWith("https://"))
            return false
        url = next
        plugin.set("registryUrl", next)
        fetch()
        return true
    }

    Process {
        id: fetcher
        stdout: StdioCollector { id: fetchOutput }
        stderr: StdioCollector { id: fetchError }
        onExited: code => {
            if (code !== 0) {
                root.status = "error"
                root.error = fetchError.text || "Could not load the registry."
                return
            }
            try {
                const payload = JSON.parse(fetchOutput.text)
                if (!payload || payload.version !== 1 || !Array.isArray(payload.plugins))
                    throw new Error("Unsupported registry format")
                root.entries = payload.plugins.filter(p => p && typeof p.id === "string" && typeof p.name === "string" && typeof p.source === "string")
                root.status = "ready"
                root.changed()
            } catch (e) {
                root.status = "error"
                root.error = String(e)
            }
        }
    }

    Process {
        id: installer
        stdout: StdioCollector { id: installOutput }
        stderr: StdioCollector { id: installError }
        onExited: code => {
            const message = (code === 0 ? installOutput.text : installError.text).trim()
            root.status = code === 0 ? "ready" : "error"
            root.error = code === 0 ? "" : (message || "Installation failed.")
            Plugins.reload()
            root.changed()
            root.operationFinished(code === 0, message)
        }
    }
}
