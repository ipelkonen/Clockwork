#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QObject>
#include <QVariantList>

class QQmlEngine;
class QJSEngine;
class QTranslator;

// Provides an interface to change the UI language
class Translator : public QObject
{
    Q_OBJECT
public:
    enum Language { Undefined, En, Fi };

private:
    // Declare enum for QML connectivity
    Q_ENUM(Language)
    // Declare language setting for QML connectivity
    Q_PROPERTY(Language language READ language WRITE setLanguage NOTIFY languageChanged)

public:
    // Standard constructor
    explicit Translator(QQmlEngine* engine, QObject *parent = nullptr);

    // Static instance getter for type registration with Qt-required format
    static QObject* singletonProvider(QQmlEngine* engine, QJSEngine* script);

    // Getter for Q_PROPERTY
    Language language() const { return m_language; }
    // Setter for Q_PROPERTY
    void setLanguage(Language language);

signals:
    // Signal emitted by a language change
    void languageChanged(Translator::Language language);

private:
    // Engine reference
    QQmlEngine* m_pEngine;
    // Active language
    Language m_language;
    // Translator reference
    QTranslator* m_pTranslator;
};

#endif // TRANSLATOR_H
