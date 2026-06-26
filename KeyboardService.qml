pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: root

    property string layout: "US"
    property string fullName: "English (US)"
    property string flag: "🇺🇸"
    property string keyboardName: ""
    property var availableLayouts: []
    property int currentLayoutIndex: 0

    // Queue of layout indices to switch to (sequential hyprctl calls)
    property var _queue: []
    property bool _busy: false
    // Count of optimistic switches in flight (hyprctl not yet confirmed)
    property int _pendingCount: 0

    // xkbName = name Hyprland uses in activelayout IPC events (XKB English display name)
    readonly property var layoutInfo: ({
        "us":    { short: "US",  full: "English (US)",      flag: "🇺🇸", xkbName: "English (US)" },
        "es":    { short: "ES",  full: "Español",            flag: "🇪🇸", xkbName: "Spanish" },
        "mx":    { short: "MX",  full: "Español (MX)",      flag: "🇲🇽", xkbName: "Spanish (Mexico)" },
        "latam": { short: "LA",  full: "Español (Lat.)",    flag: "🌎",  xkbName: "Spanish (Latin American)" },
        "de":    { short: "DE",  full: "Deutsch",            flag: "🇩🇪", xkbName: "German" },
        "fr":    { short: "FR",  full: "Français",           flag: "🇫🇷", xkbName: "French" },
        "it":    { short: "IT",  full: "Italiano",           flag: "🇮🇹", xkbName: "Italian" },
        "pt":    { short: "PT",  full: "Português",          flag: "🇵🇹", xkbName: "Portuguese" },
        "br":    { short: "BR",  full: "Português (BR)",    flag: "🇧🇷", xkbName: "Portuguese (Brazil)" },
        "ru":    { short: "RU",  full: "Русский",            flag: "🇷🇺", xkbName: "Russian" },
        "ja":    { short: "JA",  full: "日本語",              flag: "🇯🇵", xkbName: "Japanese" },
        "zh":    { short: "ZH",  full: "中文",                flag: "🇨🇳", xkbName: "Chinese" },
        "ko":    { short: "KO",  full: "한국어",              flag: "🇰🇷", xkbName: "Korean" },
        "ar":    { short: "AR",  full: "العربية",            flag: "🇸🇦", xkbName: "Arabic" },
        "pl":    { short: "PL",  full: "Polski",             flag: "🇵🇱", xkbName: "Polish" },
        "nl":    { short: "NL",  full: "Nederlands",         flag: "🇳🇱", xkbName: "Dutch" },
        "tr":    { short: "TR",  full: "Türkçe",             flag: "🇹🇷", xkbName: "Turkish" },
        "sv":    { short: "SV",  full: "Svenska",            flag: "🇸🇪", xkbName: "Swedish" },
        "no":    { short: "NO",  full: "Norsk",              flag: "🇳🇴", xkbName: "Norwegian" },
        "da":    { short: "DA",  full: "Dansk",              flag: "🇩🇰", xkbName: "Danish" },
        "fi":    { short: "FI",  full: "Suomi",              flag: "🇫🇮", xkbName: "Finnish" },
        "cs":    { short: "CS",  full: "Čeština",            flag: "🇨🇿", xkbName: "Czech" },
        "sk":    { short: "SK",  full: "Slovenčina",         flag: "🇸🇰", xkbName: "Slovak" },
        "hu":    { short: "HU",  full: "Magyar",             flag: "🇭🇺", xkbName: "Hungarian" },
        "ro":    { short: "RO",  full: "Română",             flag: "🇷🇴", xkbName: "Romanian" },
        "uk":    { short: "UA",  full: "Українська",         flag: "🇺🇦", xkbName: "Ukrainian" },
        "he":    { short: "HE",  full: "עברית",              flag: "🇮🇱", xkbName: "Hebrew" },
        "el":    { short: "EL",  full: "Ελληνικά",           flag: "🇬🇷", xkbName: "Greek" }
    })

    function getLayoutShort(code) {
        const info = layoutInfo[code.toLowerCase().trim()]
        return info ? info.short : code.toUpperCase().substring(0, 3)
    }

    function getLayoutFull(code) {
        const info = layoutInfo[code.toLowerCase().trim()]
        return info ? info.full : code.toUpperCase()
    }

    function getLayoutFlag(code) {
        const info = layoutInfo[code.toLowerCase().trim()]
        return info ? info.flag : "⌨️"
    }

    // Instantly update all display properties from index
    function _applyIndex(index) {
        if (index < 0 || index >= availableLayouts.length) return
        currentLayoutIndex = index
        const code = availableLayouts[index]
        layout = getLayoutShort(code)
        fullName = getLayoutFull(code)
        flag = getLayoutFlag(code)
    }

    // Queue next index and drain if idle
    function _enqueue(index) {
        _queue.push(index)
        _queueChanged()
        _drain()
    }

    function _drain() {
        if (_busy || _queue.length === 0 || keyboardName === "") return
        _busy = true
        const idx = _queue.shift()
        _queueChanged()
        switchProcess.command = ["hyprctl", "switchxkblayout", keyboardName, String(idx)]
        switchProcess.running = true
    }

    // Click handler: optimistic update + queue the hyprctl call
    function switchToNext() {
        if (keyboardName === "" || availableLayouts.length === 0) return
        _applyIndex((currentLayoutIndex + 1) % availableLayouts.length)
        _pendingCount++
        _enqueue(currentLayoutIndex)
    }

    function switchToIndex(index) {
        if (keyboardName === "" || index < 0 || index >= availableLayouts.length) return
        _applyIndex(index)
        _pendingCount++
        _enqueue(currentLayoutIndex)
    }

    // Hyprland IPC: activelayout fires the INSTANT the compositor switches layout
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "activelayout") return

            if (root._pendingCount > 0) {
                // Optimistic update already applied — just acknowledge
                root._pendingCount--
                return
            }

            // External change (keybind, other tool) — update from IPC data
            const parts = event.parse(2)
            if (parts.length < 2) return
            const layoutName = parts[1]
            const idx = root.findCurrentIndex(layoutName, root.availableLayouts)
            root.currentLayoutIndex = idx
            const code = root.availableLayouts[idx] || root.availableLayouts[0] || "us"
            root.layout = root.getLayoutShort(code)
            root.flag = root.getLayoutFlag(code)
            root.fullName = root.getLayoutFull(code)
        }
    }

    function deriveShortCode(activeKeymap, layouts) {
        const parenMatch = activeKeymap.match(/\(([^)]+)\)/)
        if (parenMatch) return parenMatch[1].toUpperCase().substring(0, 3)
        const lc = activeKeymap.toLowerCase()
        for (let i = 0; i < layouts.length; i++) {
            const code = layouts[i].toLowerCase().trim()
            const info = layoutInfo[code]
            if (info && lc.startsWith(info.full.toLowerCase().split(" ")[0])) return info.short
            if (lc.includes("(" + code + ")")) return code.toUpperCase().substring(0, 3)
        }
        return activeKeymap.substring(0, 2).toUpperCase()
    }

    function findCurrentIndex(activeKeymap, layouts) {
        const lc = activeKeymap.toLowerCase().trim()
        for (let i = 0; i < layouts.length; i++) {
            const code = layouts[i].toLowerCase().trim()
            if (lc.includes("(" + code + ")")) return i
            const info = layoutInfo[code]
            if (!info) continue
            // Match against our display name
            if (lc === info.full.toLowerCase()) return i
            if (lc.startsWith(info.full.toLowerCase().split(" ")[0])) return i
            // Match against Hyprland's XKB English name (used in activelayout events)
            if (info.xkbName && lc === info.xkbName.toLowerCase()) return i
            if (info.xkbName && lc.startsWith(info.xkbName.toLowerCase())) return i
        }
        return 0
    }

    function parseDevices(jsonText) {
        try {
            const data = JSON.parse(jsonText)
            const kbs = data.keyboards || []
            for (let i = 0; i < kbs.length; i++) {
                const kb = kbs[i]
                if (kb.name && (kb.name.includes("virtual") || kb.name.includes("xtest")))
                    continue
                root.keyboardName = kb.name || ""
                const activeKeymap = kb["active_keymap"] || kb.activeKeymap || ""
                const activeIndex = kb["active_layout_index"] !== undefined ? kb["active_layout_index"]
                                  : (kb.active_layout_index !== undefined ? kb.active_layout_index : -1)
                const layoutField = kb.layout || "us"
                const layouts = layoutField.split(",").map(l => l.trim()).filter(l => l.length > 0)
                root.availableLayouts = layouts

                // Don't override optimistic/IPC-updated state
                if (root._pendingCount > 0) break

                if (activeIndex >= 0 && activeIndex < layouts.length) {
                    root.currentLayoutIndex = activeIndex
                    const code = layouts[activeIndex]
                    root.layout = root.getLayoutShort(code)
                    root.fullName = activeKeymap || root.getLayoutFull(code)
                    root.flag = root.getLayoutFlag(code)
                } else {
                    root.fullName = activeKeymap || "Unknown"
                    root.layout = root.deriveShortCode(root.fullName, layouts)
                    root.currentLayoutIndex = root.findCurrentIndex(root.fullName, layouts)
                    const code = layouts[root.currentLayoutIndex] || layouts[0] || "us"
                    root.flag = root.getLayoutFlag(code)
                }
                break
            }
        } catch(e) {
            devicesTextFallback.running = true
        }
    }

    Process {
        id: switchProcess
        running: false
        onExited: {
            root._busy = false
            root._drain()
        }
    }

    // Initial state fetch on startup
    Process {
        id: devicesProcess
        command: ["hyprctl", "devices", "-j"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.parseDevices(text)
        }
    }

    Process {
        id: devicesTextFallback
        command: ["bash", "-c", "hyprctl devices | grep 'active keymap' | head -1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/active keymap:\s*(.+)/)
                if (match) {
                    root.fullName = match[1].trim()
                    const layouts = root.availableLayouts.length > 0 ? root.availableLayouts : ["us"]
                    root.layout = root.deriveShortCode(root.fullName, layouts)
                }
            }
        }
    }

    // Periodic re-sync to catch edge cases (keyboard reconnect, etc.)
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            if (!devicesProcess.running && root._pendingCount === 0 && !root._busy)
                devicesProcess.running = true
        }
    }
}
