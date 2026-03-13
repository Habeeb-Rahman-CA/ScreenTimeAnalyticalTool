#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "usagetracker.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    UsageTracker tracker;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("usageTracker", &tracker);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ScreenTimeAnalyticalTool", "Main");

    return app.exec();
}
