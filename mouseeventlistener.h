#ifndef MOUSEEVENTLISTENER_H
#define MOUSEEVENTLISTENER_H

#include <QObject>
#include <QPointF>

class QQmlEngine;
class QJSEngine;

// This class detects mouse movements and passes them as emitted signals to be used by QML.
// The class is a singleton. See main.cpp for connecting the class to QML.
class MouseEventListener : public QObject
{
    Q_OBJECT
public:
    // Standard constructor
    explicit MouseEventListener(QObject *parent = nullptr);

    // Static instance getter for type registration with Qt-required format
    static QObject* singletonProvider(QQmlEngine* engine, QJSEngine* script);

protected:
    // Event filter called by the framework when an event occurs
    bool eventFilter(QObject* watched, QEvent* event);

signals:
    // Emitted signal when mouse movement is detected
    void mouseEventDetected(QPointF position);
};

#endif // MOUSEEVENTLISTENER_H
