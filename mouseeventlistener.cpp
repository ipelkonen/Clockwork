#include "mouseeventlistener.h"
#include <QGuiApplication>
#include <QMouseEvent>

MouseEventListener::MouseEventListener(QObject *parent)
    : QObject{parent}
{
}

QObject* MouseEventListener::singletonProvider(QQmlEngine* engine, QJSEngine* script)
{
    Q_UNUSED(engine)
    Q_UNUSED(script)

    // Create singleton instance
    MouseEventListener* instance = new MouseEventListener();

    // Install the listener as an event filter to the application
    qGuiApp->installEventFilter(instance);

    // Return the created object
    return instance;
}

bool MouseEventListener::eventFilter(QObject* watched, QEvent* event)
{
    // Filter for mouse movement event
    if (event->type() == QEvent::MouseMove) {
        // Emit signal to be captured by the QML
        emit mouseEventDetected(static_cast<QMouseEvent*>(event)->position());
    }

    // Always call default event handling afterwards
    return QObject::eventFilter(watched, event);
}
