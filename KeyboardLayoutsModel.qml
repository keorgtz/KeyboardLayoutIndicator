import QtQuick

QtObject {
    id: root

    readonly property var items: {
        const layouts = KeyboardService.availableLayouts
        return layouts.map((code, i) => ({
            code: code.trim(),
            shortName: KeyboardService.getLayoutShort(code.trim()),
            fullName: KeyboardService.getLayoutFull(code.trim()),
            index: i,
            isActive: i === KeyboardService.currentLayoutIndex
        }))
    }

    readonly property int count: items.length
}
