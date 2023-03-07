#include "translator.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QTranslator>

Translator::Translator(QQmlEngine* engine, QObject* parent)
    : QObject{parent},
      m_pEngine(engine),
      m_language(Language::Undefined),
      m_pTranslator(new QTranslator())
{
}

QObject *Translator::singletonProvider(QQmlEngine *engine, QJSEngine *script)
{
    Q_UNUSED(engine)
    Q_UNUSED(script)
    return new Translator(engine);
}

void Translator::setLanguage(Language language)
{
    if (language == m_language) {
        return;
    }

    // Determine file name based on enumeration value
    QString filename = "";
    switch (language) {
    case Language::Fi:
        filename = "fi";
        break;
    case Language::En:
        filename = "en";
        break;
    default:
        return;
    }

    // Remove old translator if it exists
    if (!m_pTranslator->isEmpty()) {
        QCoreApplication::removeTranslator(m_pTranslator);
    }

    // Load the new translations
    if (!m_pTranslator->load(filename)) {
        return;
    }

    // Install the translator
    if (!QCoreApplication::installTranslator(m_pTranslator)) {
        return;
    }

    // Update internal variable
    m_language = language;

    // Retranslate the UI
    m_pEngine->retranslate();
}
