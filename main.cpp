#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "translator.h"
#include "mouseeventlistener.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QCoreApplication::setApplicationName( QString("Clockwork") );
    QQmlApplicationEngine engine;

    // Register language changing class as a singleton to be used in QML
    // Parameters: desired namespace, versionHigh, versionLow, desired qmlObjectName, singleton getter
    // These have to be registered before loading the QML to be able to use them in the QML!
    qmlRegisterSingletonType<Translator>("Translator", 1, 0, "Translator",
                                         Translator::singletonProvider);

    // Register mouse event listener as a singleton to be used in QML
    qmlRegisterSingletonType<MouseEventListener>("MouseEventListener", 1, 0, "MouseEventListener",
                                                 MouseEventListener::singletonProvider);

    const QUrl url(u"qrc:/Clockwork/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
