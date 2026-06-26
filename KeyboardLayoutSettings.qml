import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "keyboardLayoutIndicator"

    StyledText {
        width: parent.width
        text: "Keyboard Layout"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Shows the active keyboard layout in your bar. Left-click switches layout, right-click opens the layout picker."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    ToggleSetting {
        settingKey: "showFlag"
        label: "Show Flag"
        description: "Show the country flag emoji for the active layout"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showText"
        label: "Show Layout Code"
        description: "Show the layout code (e.g. US, DE, FR) in the bar"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showFullName"
        label: "Show Full Language Name"
        description: "Show full name (e.g. English (US)) instead of the short code"
        defaultValue: false
    }

    SliderSetting {
        settingKey: "refreshInterval"
        label: "Refresh Interval"
        description: "How often to poll for layout changes (milliseconds)"
        defaultValue: 2000
        minimum: 500
        maximum: 10000
        unit: "ms"
        leftIcon: "timer"
        rightIcon: "speed"
    }

    StyledText {
        width: parent.width
        text: "💡 Tip: Left-click the widget to instantly cycle through your configured layouts. Right-click to open the full layout picker."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }
}
