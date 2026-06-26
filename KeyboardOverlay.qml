pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

PanelWindow {
    id: overlay

    required property var overlayScreen
    screen: overlayScreen
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "keyboard-layout-overlay"

    implicitWidth: 300
    implicitHeight: 130

    property bool showing: false

    function show() {
        showing = true
        dismissTimer.restart()
    }

    Connections {
        target: KeyboardService
        function onLayoutChanged() { overlay.show() }
    }

    Timer {
        id: dismissTimer
        interval: 1500
        onTriggered: overlay.showing = false
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: parent.width - 20
        height: parent.height - 20
        radius: Theme.cornerRadius + 10

        color: Theme.withAlpha(Theme.surfaceContainer, 0.96)
        border.color: Theme.withAlpha(Theme.primary, 0.22)
        border.width: 1

        opacity: overlay.showing ? 1.0 : 0.0
        scale: overlay.showing ? 1.0 : 0.72

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.shortDuration
                easing.type: Easing.OutBack
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.spacingM

            Text {
                text: KeyboardService.flag
                font.pixelSize: 44
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
                lineHeight: 1
            }

            Column {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    text: KeyboardService.layout
                    font.pixelSize: 36
                    font.weight: Font.Bold
                    color: Theme.primary
                }

                StyledText {
                    text: KeyboardService.fullName
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                }
            }
        }
    }
}
