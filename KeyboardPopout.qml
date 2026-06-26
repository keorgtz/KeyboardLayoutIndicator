import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PopoutComponent {
    id: root

    headerText: "Keyboard Layout"
    showCloseButton: true

    Item {
        width: parent.width
        implicitHeight: currentSection.implicitHeight + Theme.spacingL

        Column {
            id: currentSection
            width: parent.width - Theme.spacingM * 2
            x: Theme.spacingS
            spacing: Theme.spacingXS

            StyledText {
                text: "Active"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            Row {
                spacing: Theme.spacingM

                Text {
                    text: KeyboardService.flag
                    font.pixelSize: 32
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                    lineHeight: 1
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        text: KeyboardService.layout
                        font.pixelSize: Theme.fontSizeXLarge + 4
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

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.withAlpha(Theme.outline, 0.15)
    }

    Item {
        width: parent.width
        implicitHeight: Theme.spacingXS
    }

    StyledText {
        leftPadding: Theme.spacingS
        text: KeyboardService.availableLayouts.length > 1 ? "Available Layouts" : "Layout"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
    }

    Repeater {
        model: KeyboardService.availableLayouts

        delegate: Rectangle {
            id: layoutDelegate

            required property string modelData
            required property int index

            readonly property bool isActive: index === KeyboardService.currentLayoutIndex
            property bool hovered: delegateArea.containsMouse

            width: parent.width
            implicitHeight: 52
            radius: Theme.cornerRadius
            color: isActive
                   ? Theme.withAlpha(Theme.primary, 0.12)
                   : (hovered ? Theme.withAlpha(Theme.surfaceText, 0.06) : "transparent")

            Behavior on color {
                ColorAnimation {
                    duration: Theme.shortDuration
                    easing.type: Theme.standardEasing
                }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacingM
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingS

                Text {
                    text: KeyboardService.getLayoutFlag(modelData)
                    font.pixelSize: Theme.fontSizeMedium + 2
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                    lineHeight: 1
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        text: KeyboardService.getLayoutShort(modelData)
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.DemiBold
                        color: isActive ? Theme.primary : Theme.surfaceText
                    }

                    StyledText {
                        text: KeyboardService.getLayoutFull(modelData)
                        font.pixelSize: Theme.fontSizeSmall
                        color: isActive ? Theme.withAlpha(Theme.primary, 0.75) : Theme.surfaceVariantText
                    }
                }
            }

            Rectangle {
                width: 3
                height: parent.height * 0.45
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingXS
                anchors.verticalCenter: parent.verticalCenter
                radius: 2
                color: Theme.primary
                visible: isActive
                opacity: isActive ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.standardEasing
                    }
                }
            }

            MouseArea {
                id: delegateArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: isActive ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: {
                    if (!isActive) KeyboardService.switchToIndex(index)
                }
            }
        }
    }

    Item {
        width: parent.width
        implicitHeight: Theme.spacingS
    }
}
