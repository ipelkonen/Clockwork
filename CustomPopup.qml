import QtQuick
import QtQuick.Controls
import Translator // C++ singleton class

// Custom popup to display game start and finish data
Popup {
    id: popup
    // Center the popup to the window
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: 500
    height: 300
    modal: true
    closePolicy: Popup.NoAutoClose // Only a button click closes the popup

    property string title: "" // Popup title
    property string prompt: "" // Popup text
    property string button: "" // Button text

    // Background rectangle
    background: Rectangle {
        opacity: 0.7
        radius: 20
        gradient: Gradient {
            GradientStop { position: 0; color: "#404040" }
            GradientStop { position: 1; color: "black" }
        }

        border { color: "#404040"; width: 2 }
    }

    // Title text
    Text {
        id: textTitle
        text: popup.title
        anchors { top: parent.top; topMargin: 30 }
        width: parent.width
        color: "lightgray"
        horizontalAlignment: Text.AlignHCenter
        font { pixelSize: 30; family: "chilanka"; bold: true }
    }

    // Message text
    Text {
        text: popup.prompt
        anchors { top: textTitle.bottom; topMargin: 20 }
        width: parent.width
        color: "lightgray"
        horizontalAlignment: Text.AlignHCenter
        font { pixelSize: 20; family: "chilanka"; bold: true }
    }

    // Button
    Rectangle {
        id: button
        x: (parent.width - width) / 2
        y: parent.height / 5 * 3
        width: 200
        height: 60
        opacity: 0.7
        color: mouseArea.containsMouse ? "#808080" : "#a0a0a0"
        border.color: "#202020"
        border.width: 2
        radius: 10

        Text {
            text: popup.button
            font: textTitle.font
            opacity: 0.8
            color: "black"
            anchors { fill: parent; bottomMargin: 10 }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            elide: Text.ElideRight
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { popup.close() }
        }
    }

    // Language selection
    Item {
        x: (parent.width - width) / 2
        width: labelLanguage.width + comboLanguage.width + comboLanguage.anchors.leftMargin
        anchors { top: button.top; bottom: parent.bottom }

        // Label
        Text {
            id: labelLanguage
            text: qsTr("Language:")
            anchors { bottom: parent.bottom; bottomMargin: 15 }
            color: "lightgray"
            verticalAlignment: Text.AlignBottom
            font {
                pixelSize: 16
                family: "chilanka"
                bold: true
            }
        }

        // Language selection combo box
        CustomComboBox {
            id: comboLanguage
            anchors { left: labelLanguage.right; leftMargin: 5; bottom: parent.bottom; bottomMargin: 10 }
            height: 30
            font: labelLanguage.font

            // Separate text and value in the model
            textRole: "text"
            valueRole: "value"

            model: [
                { value: Translator.En, text: "English" },
                { value: Translator.Fi, text: "Suomi" }
            ]

            onActivated: Translator.language = currentValue // This calls C++ setter Translator::setLanguage() in accordance to the Q_PROPERTY binding
        }
    }

    onAboutToShow: comboLanguage.currentIndex = Translator.language
}
