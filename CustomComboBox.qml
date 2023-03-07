import QtQuick
import QtQuick.Controls

// Custom combobox control
ComboBox {
    id: control

    // Popup delegate
    delegate: ItemDelegate {
        width: control.width
        height: control.height
        // Non-selected popup item
        contentItem: Rectangle {
            anchors.fill: parent
            color: "#202020" // Background color
            Text {
                anchors {
                    fill: parent
                    leftMargin: 5 // Shift texts a little to the right
                }
                // Dig item text from the model
                text: control.textRole
                    ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole])
                    : modelData
                color: "lightgray" // Foreground color
                font: control.font // Listview font
                elide: Text.ElideRight // Non-fitting text elided from the right
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Draw a simple triangle as a combobox indicator
    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() { canvas.requestPaint(); }
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.pressed ? "#404040" : "#808080";
            context.fill();
        }
    }

    // Draw selected item (combobox closed status)
    contentItem: Text {
        leftPadding: 0
        rightPadding: control.indicator.width + control.spacing
        text: control.displayText
        font: control.font
        color: control.pressed ? "gray" : "lightgray"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // Draw background of selected item (combobox closed status)
    background: Rectangle {
        implicitWidth: control.width
        implicitHeight: control.height
        opacity: 0.5
        color: "darkgray"
        border.color: control.pressed ? "lightgray" : "white"
        border.width: control.visualFocus ? 2 : 1
        radius: 5
    }

    // Popup menu extra configuration
    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight + 2
            model: control.delegateModel
            currentIndex: control.highlightedIndex

            // Highlight row configuration
            highlight: Rectangle {
                z: 5 // Z order needs to be explicitly set to a higher number for the rectangle to be on top
                opacity: 0.4
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#808080" }
                    GradientStop { position: 1.0; color: "#202020" }
                }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        // Popup background - affects only borders
        background: Rectangle {
            color: "black"
        }
    }
}
