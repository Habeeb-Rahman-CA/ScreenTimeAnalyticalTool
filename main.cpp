#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "databasemanager.h"
#include "usagetracker.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    DatabaseManager dbManager;
    if (!dbManager.initializeDatabase()) {
        qWarning() << "Failed to initialize database!";
    }

    UsageTracker tracker(&dbManager);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("dbManager", &dbManager);
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
