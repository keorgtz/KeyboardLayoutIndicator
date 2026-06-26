import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Modules.Bar

BarWidget {

    id: root

    implicitWidth: 45

    property string layout: "US"

    Process {
        id: layoutProcess

        command: [
            "bash",
            "-c",
            "hyprctl devices | grep 'active keymap' | head -1 | cut -d':' -f2"
        ]

        stdout: StdioCollector {

            onStreamFinished: {

                if (text.includes("English"))
                    root.layout = "US"
                else
                    root.layout = "ES"

            }

        }

    }

    Timer {

        interval: 1000

        running: true

        repeat: true

        onTriggered: layoutProcess.running = true

    }

    Label {

        anchors.centerIn: parent

        text: root.layout

        font.bold: true

    }

}
