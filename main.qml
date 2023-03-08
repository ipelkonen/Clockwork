import QtQuick
import MouseEventListener // C++ singleton class

Window {
    id: window
    width: Screen.width
    height: Screen.height
    visible: true
    title: qsTr("Clockwork")
    flags: Qt.FramelessWindowHint // Hide window borders

    // Game score
    property real score: 0
    // Game timer
    property int timer: 0
    // Game running flag
    property bool running: timer > 0
    // Game finished flag
    property bool finished: false

    // Startup popup
    CustomPopup {
        title: window.title
        prompt: qsTr("Please start the game below.")
        button: qsTr("Start Game")
        visible: true
        onClosed: window.timer = 60000
    }

    // End of game popup
    CustomPopup {
        title: qsTr("Game Over")
        prompt: qsTr("Final score: %L1").arg(Math.floor(window.score))
        button: qsTr("New Game")
        visible: window.finished
        onClosed: {
            // Reset parameters
            window.score = 0;
            shader.centerX = window.initCenterX();
            shader.centerY = window.initCenterY();
            shader.speed = 1.0;
            shader.direction = window.initDirection();
            window.timer = 60000;
            window.finished = false;
        }
    }

    // Bottom area of the screen
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 50
        color: "black"

        // Time left progress bar background
        Rectangle {
            id: progressBackground
            anchors { top: parent.top; topMargin: 5; left: parent.left; leftMargin: 5; right: parent.right; rightMargin: 5 }
            height: 5
            color: "lightgray"
            visible: window.running
        }

        // Time left progress bar
        Rectangle {
            anchors { top: parent.top; topMargin: 5; left: parent.left; leftMargin: 5 }
            width: progressBackground.width * window.timer / 60000
            height: 5
            color: "red"
            opacity: 0.5
            visible: window.running
        }

        // Time remaining text
        Text {
            anchors { left: parent.left; leftMargin: 10; bottom: textScore.bottom }
            color: "lightgray"
            font: textScore.font
            // Fade in in 1s
            NumberAnimation on opacity { from: 0; to: 1; duration: 1000; running: window.running }
            visible: window.running
            text: qsTr("Time remaining: %1").arg((window.timer / 1000.0).toFixed(1))
        }

        // Score indicator
        Text {
            id: textScore
            text: qsTr("Score: %L1").arg(Math.floor(score))
            width: parent.width
            height: parent.height - 5
            color: "lightgray"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            font {
                pixelSize: 25
                family: "chilanka"
                bold: true
            }
        }

        // Clock image copyright text
        Text {
            text: qsTr("Clock image by %1 on %2").arg("onlyyouqj").arg("Freepik")
            width: parent.width
            height: parent.height - 5
            color: "lightgray"
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            font {
                pixelSize: 10
                family: "chilanka"
            }
        }
    }

    // Stored mouse coordinates
    property point mousePos: "0, 0"

    // Connection to C++
    Connections {
        target: MouseEventListener
        // C++ signal detecting mouse movement
        function onMouseEventDetected(position) {
            mousePos = position; // Update mouse position
        }
    }

    // Calculates hour pointer angle for the clock
    // The pointer is adjusted by score!
    function getHourAngle() {
        const date = new Date(new Date().getTime() + Math.floor(score) * 1000);
        return (date.getHours() + date.getMinutes() / 60) / 12 * 360.0;
    }

    // Calculates minute pointer angle for the clock
    // The pointer is adjusted by score!
    function getMinuteAngle() {
        const date = new Date(new Date().getTime() + Math.floor(score) * 1000);
        return (date.getMinutes() + date.getSeconds() / 60) / 60 * 360.0;
    }

    // Calculates second pointer angle for the clock
    // The pointer is adjusted by score!
    function getSecondAngle() {
        const date = new Date(new Date().getTime() + Math.floor(score) * 1000);
        return date.getSeconds() / 60 * 360.0;
    }

    function initCenterX() {
        return Math.random() * (background.width - clockImage.width / 3);
    }

    function initCenterY() {
        return Math.random() * (background.height - clockImage.height / 3);
    }

    function initDirection() {
        return Math.random() * 2 * Math.PI;
    }

    // Background image and clockwork area
    Image {
        id: background
        width: parent.width
        height: parent.height - 50
        source: "qrc:/clock/the-persistence-of-memory-painting-by-salvador-dali-uhd-4k-wallpaper.jpg"
        fillMode: Image.Stretch // Shrink/stretch the image to viewport size

        // Source mapping for the wobble effect
        ShaderEffectSource {
            id: shaderSource
            sourceItem: clockCanvas
        }

        // Wrap original clock image into a Canvas component to be able to use it as the wobble source
        Canvas {
            id: clockCanvas
            width: clockImage.width
            height: clockImage.height
            visible: false // Do not display the original image without wobble effect

            // Clock background
            Image {
                id: clockImage
                source: "qrc:/clock/bkg.png"
                width: 300
                height: 300
                property real safeArea: width / 3 // The image(s) include some extra around for the wobble effect
                fillMode: Image.PreserveAspectFit
            }

            // Second pointer behind hour and minute pointers
            Image {
                id: secondImage
                source: "qrc:/clock/second.png"
                width: clockImage.width
                height: clockImage.height
                fillMode: Image.PreserveAspectFit
                rotation: window.getSecondAngle()
            }

            // Hour pointer
            Image {
                id: hourImage
                source: "qrc:/clock/hour.png"
                width: clockImage.width
                height: clockImage.height
                fillMode: Image.PreserveAspectFit
                rotation: window.getHourAngle()
            }

            // Minute pointer
            Image {
                id: minuteImage
                source: "qrc:/clock/minute.png"
                width: clockImage.width
                height: clockImage.height
                fillMode: Image.PreserveAspectFit
                rotation: window.getMinuteAngle()
            }
        }

        // Wobbling clock
        ShaderEffect {
            id: shader

            // X and Y coordinates are automatically updated from center(x, y) by these formulas on the go!
            x: centerX - clockImage.width / 2
            y: centerY - clockImage.height / 2
            width: clockImage.width
            height: clockImage.height
            visible: window.running

            // Alias for clock background safe area
            property alias safeArea: clockImage.safeArea

            // Shader parameters - these have to match wobble.frag!
            property var src: shaderSource
            property real time: 0
            property real frequency: 10
            property real amplitude: 0.015
            fragmentShader: "qrc:/shaders/wobble.frag.qsb"

            // Animate wobble effect
            NumberAnimation on time { loops: Animation.Infinite; from: 0; to: Math.PI * 2; duration: 6000 }

            // Center(x, y) define the actual position of the wobbled clock
            property real centerX: window.initCenterX()
            property real centerY: window.initCenterY()

            // Speed of the clock
            property real speed: 1.0

            // Direction of the clock
            property real direction: window.initDirection()

            // 20ms timer to update everything
            Timer {
                interval: 20
                running: window.running
                repeat: true
                onTriggered: {
                    // Update coordinates
                    shader.centerX += Math.cos(parent.direction) * parent.speed;
                    shader.centerY += Math.sin(parent.direction) * parent.speed;

                    // Bounce from X walls
                    if (shader.x < -shader.safeArea / 2 || shader.x > background.width - (shader.width - shader.safeArea / 2)) {
                        parent.direction = Math.PI - parent.direction;
                        shader.centerX = Math.max(shader.safeArea, Math.min(shader.centerX, background.width - (shader.width - shader.safeArea) / 2));
                    }

                    // Bounce from Y walls
                    if (shader.y < -shader.safeArea / 2 || shader.y > background.height - (shader.height - shader.safeArea / 2)) {
                        parent.direction = Math.PI*2 - parent.direction;
                        shader.centerY = Math.max(shader.safeArea, Math.min(shader.centerY, background.height - (shader.height - shader.safeArea) / 2));
                    }

                    // Update time shown by the clock
                    hourImage.rotation = getHourAngle();
                    minuteImage.rotation = getMinuteAngle();
                    secondImage.rotation = getSecondAngle();

                    // Find vector components from the mouse to the clock (non-wobbled) center point
                    const vectorX = shader.centerX - window.mousePos.x;
                    const vectorY = shader.centerY - window.mousePos.y;

                    // Calculate mouse distance to the center point
                    const distance = Math.sqrt(Math.pow(vectorX, 2) + Math.pow(vectorY, 2));
                    if (distance < 100) {
                        // We're on the clock - add to score
                        window.score += 10 / (distance + 1);
                    }

                    // Get vector angle
                    const theta = Math.atan2(vectorY, vectorX);

                    if (distance < 300) {
                        // We're near the clock - adjust speed and direction
                        parent.speed = Math.min(20, parent.speed * (1.0 + (300 - distance) / 5000));
                        parent.direction += theta / 50;
                    }

                    // Return speed gradually to normal
                    parent.speed = Math.max(1.0, parent.speed / 1.004);

                    // Update timer and finished flag
                    window.timer -= 20;
                    if (window.timer <= 0) {
                        window.finished = true;
                    }
                }
            }
        }
    }
}
