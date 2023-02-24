import QtQuick

Window {
    id: window
    width: Screen.width
    height: Screen.height
    visible: true
    title: qsTr("Clockwork")
    flags: Qt.FramelessWindowHint

    property real score: 0

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 50
        color: "black"

        Text {
            text: "Score: " + Math.floor(score)
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

        Text {
            text: "Clock image by onlyyouqj on Freepik"
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

    property real mouseX: 0
    property real mouseY: 0

    function getHourAngle() {
        const date = new Date(new Date().getTime() + Math.floor(score) * 1000)
        return (date.getHours() + date.getMinutes() / 60) / 12 * 360.0
    }

    function getMinuteAngle() {
        const date = new Date(new Date().getTime() + Math.floor(score) * 1000)
        return (date.getMinutes() + date.getSeconds() / 60) / 60 * 360.0
    }

    function getSecondAngle() {
        const date = new Date(new Date().getTime() + Math.floor(score) * 1000);
        return date.getSeconds() / 60 * 360.0;
    }

    function getTheta(v) {
        if (v.x === 0) {
            return v.y > 0 ? Math.PI / 2 : v.y === 0 ? 0 : -Math.PI / 2
        }

        const theta = Math.atan(v.y / v.x)
        const absTheta = Math.abs(theta)

        if (v.x > 0) {
            if (v.y > 0) {
                return absTheta
            }

            return 2 * Math.PI - absTheta
        }

        if (v.y > 0) {
            return Math.PI - absTheta
        }

        return Math.PI + absTheta
    }

    Image {
        id: background
        width: parent.width
        height: parent.height - 50
        source: "qrc:/clock/the-persistence-of-memory-painting-by-salvador-dali-uhd-4k-wallpaper.jpg"
        fillMode: Image.Stretch

        ShaderEffectSource {
            id: shaderSource
            sourceItem: clockCanvas
        }

        Canvas {
            id: clockCanvas
            width: clockImage.width
            height: clockImage.height
            visible: false

            Image {
                id: clockImage
                source: "qrc:/clock/bkg.png"
                width: 300
                height: 300
                property real safeArea: width / 3
                fillMode: Image.PreserveAspectFit
            }

            Image {
                id: secondImage
                source: "qrc:/clock/second.png"
                width: clockImage.width
                height: clockImage.height
                fillMode: Image.PreserveAspectFit
                transform: Rotation {
                    id: secondRotation
                    origin.x: 150; origin.y: 150; angle: window.getSecondAngle()
                }
            }

            Image {
                id: hourImage
                source: "qrc:/clock/hour.png"
                width: clockImage.width
                height: clockImage.height
                fillMode: Image.PreserveAspectFit
                transform: Rotation {
                    id: hourRotation
                    origin.x: 150; origin.y: 150; angle: window.getHourAngle()
                }
            }

            Image {
                id: minuteImage
                source: "qrc:/clock/minute.png"
                width: clockImage.width
                height: clockImage.height
                fillMode: Image.PreserveAspectFit
                transform: Rotation {
                    id: minuteRotation
                    origin.x: 150; origin.y: 150; angle: window.getMinuteAngle()
                }
            }
        }

        ShaderEffect {
            id: shader
            x: centerX - clockImage.width / 2
            y: centerY - clockImage.height / 2
            width: clockImage.width
            height: clockImage.height

            property real safeArea: clockImage.safeArea
            property var src: shaderSource
            property real time: 0
            NumberAnimation on time { loops: Animation.Infinite; from: 0; to: Math.PI * 2; duration: 6000 }
            property real frequency: 10
            property real amplitude: 0.015
            fragmentShader: "qrc:/shaders/wobble.frag.qsb"

            property real centerX: Math.random() * (background.width - clockImage.width / 3)
            property real centerY: Math.random() * (background.height - clockImage.height / 3)
            property real speed: 1.0
            property real direction: Math.random() * 2 * Math.PI

            Timer {
                interval: 20; running: true; repeat: true
                onTriggered: {
                    shader.centerX += Math.cos(parent.direction) * parent.speed
                    shader.centerY += Math.sin(parent.direction) * parent.speed
                    if (shader.x < -shader.safeArea / 2 || shader.x > background.width - (shader.width - shader.safeArea / 2)) {
                        parent.direction = Math.PI - parent.direction
                        shader.centerX = Math.max(shader.safeArea, Math.min(shader.centerX, background.width - (shader.width - shader.safeArea) / 2))
                    }
                    if (shader.y < -shader.safeArea / 2 || shader.y > background.height - (shader.height - shader.safeArea / 2)) {
                        parent.direction = Math.PI*2 - parent.direction
                        shader.centerY = Math.max(shader.safeArea, Math.min(shader.centerY, background.height - (shader.height - shader.safeArea) / 2))
                    }

                    hourRotation.angle = getHourAngle()
                    minuteRotation.angle = getMinuteAngle()
                    secondRotation.angle = getSecondAngle()

                    const vectorX = shader.centerX - window.mouseX
                    const vectorY = shader.centerY - window.mouseY

                    const distance = Math.sqrt(Math.pow(vectorX, 2) + Math.pow(vectorY, 2))
                    if (distance < 100) {
                        window.score += 10 / (distance + 1)
                    }

                    const theta = window.getTheta(Qt.vector2d(vectorX, vectorY))

                    if (distance < 300) {
                        parent.speed = Math.min(20, parent.speed * (1.0 + (300 - distance) / 5000))
                        parent.direction += (theta - Math.PI) / 50
                    }

                    parent.speed = Math.max(1.0, parent.speed / 1.01)
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onMouseXChanged: window.mouseX = mouseX
        onMouseYChanged: window.mouseY = mouseY
    }
}
