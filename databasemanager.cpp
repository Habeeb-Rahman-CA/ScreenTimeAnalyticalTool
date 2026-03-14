#include "databasemanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDateTime>
#include <QDir>
#include <QStandardPaths>
#include <QVariant>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::initializeDatabase()
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dataDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    
    m_db.setDatabaseName(dataDir + "/screentime.db");
    
    if (!m_db.open()) {
        qDebug() << "Error: connection with database failed" << m_db.lastError();
        return false;
    }

    createTables();
    return true;
}

void DatabaseManager::createTables()
{
    QSqlQuery query(m_db);
    
    query.exec("CREATE TABLE IF NOT EXISTS app_usage_logs ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, "
               "app_name TEXT, "
               "duration INTEGER)");

    query.exec("CREATE TABLE IF NOT EXISTS daily_summaries ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "date_str TEXT, "
               "app_name TEXT, "
               "total_duration INTEGER, "
               "UNIQUE(date_str, app_name))");

    query.exec("CREATE TABLE IF NOT EXISTS weekly_summaries ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "year INTEGER, "
               "week INTEGER, "
               "app_name TEXT, "
               "total_duration INTEGER, "
               "UNIQUE(year, week, app_name))");

    query.exec("CREATE TABLE IF NOT EXISTS monthly_summaries ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "year INTEGER, "
               "month INTEGER, "
               "app_name TEXT, "
               "total_duration INTEGER, "
               "UNIQUE(year, month, app_name))");
}

void DatabaseManager::logAppUsage(const QString &appName, int durationSeconds)
{
    if (durationSeconds <= 0) return;

    QSqlQuery query(m_db);
    query.prepare("INSERT INTO app_usage_logs (app_name, duration) VALUES (:app_name, :duration)");
    query.bindValue(":app_name", appName);
    query.bindValue(":duration", durationSeconds);
    if (!query.exec()) {
        qDebug() << "Failed to insert log:" << query.lastError();
    }

    QDateTime now = QDateTime::currentDateTime();
    QString dateStr = now.toString("yyyy-MM-dd");
    int year = now.date().year();
    int month = now.date().month();
    int week = now.date().weekNumber();

    updateDailySummary(dateStr, appName, durationSeconds);
    updateWeeklySummary(year, week, appName, durationSeconds);
    updateMonthlySummary(year, month, appName, durationSeconds);
}

void DatabaseManager::updateDailySummary(const QString &dateStr, const QString &appName, int durationSeconds)
{
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO daily_summaries (date_str, app_name, total_duration) "
                  "VALUES (:date_str, :app_name, :dur) "
                  "ON CONFLICT(date_str, app_name) DO UPDATE SET "
                  "total_duration = total_duration + :dur");
    query.bindValue(":date_str", dateStr);
    query.bindValue(":app_name", appName);
    query.bindValue(":dur", durationSeconds);
    query.exec();
}

void DatabaseManager::updateWeeklySummary(int year, int week, const QString &appName, int durationSeconds)
{
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO weekly_summaries (year, week, app_name, total_duration) "
                  "VALUES (:year, :week, :app_name, :dur) "
                  "ON CONFLICT(year, week, app_name) DO UPDATE SET "
                  "total_duration = total_duration + :dur");
    query.bindValue(":year", year);
    query.bindValue(":week", week);
    query.bindValue(":app_name", appName);
    query.bindValue(":dur", durationSeconds);
    query.exec();
}

void DatabaseManager::updateMonthlySummary(int year, int month, const QString &appName, int durationSeconds)
{
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO monthly_summaries (year, month, app_name, total_duration) "
                  "VALUES (:year, :month, :app_name, :dur) "
                  "ON CONFLICT(year, month, app_name) DO UPDATE SET "
                  "total_duration = total_duration + :dur");
    query.bindValue(":year", year);
    query.bindValue(":month", month);
    query.bindValue(":app_name", appName);
    query.bindValue(":dur", durationSeconds);
    query.exec();
}

QVariantList DatabaseManager::getDailySummary(const QString &dateStr)
{
    QVariantList list;
    QSqlQuery query(m_db);
    query.prepare("SELECT app_name, total_duration FROM daily_summaries WHERE date_str = :date ORDER BY total_duration DESC");
    query.bindValue(":date", dateStr);
    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["name"] = query.value(0).toString();
            map["time"] = query.value(1).toInt();
            list.append(map);
        }
    }
    return list;
}

QVariantList DatabaseManager::getWeeklySummary(int year, int week)
{
    QVariantList list;
    QSqlQuery query(m_db);
    query.prepare("SELECT app_name, total_duration FROM weekly_summaries WHERE year = :year AND week = :week ORDER BY total_duration DESC");
    query.bindValue(":year", year);
    query.bindValue(":week", week);
    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["name"] = query.value(0).toString();
            map["time"] = query.value(1).toInt();
            list.append(map);
        }
    }
    return list;
}

QVariantList DatabaseManager::getMonthlySummary(int year, int month)
{
    QVariantList list;
    QSqlQuery query(m_db);
    query.prepare("SELECT app_name, total_duration FROM monthly_summaries WHERE year = :year AND month = :month ORDER BY total_duration DESC");
    query.bindValue(":year", year);
    query.bindValue(":month", month);
    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["name"] = query.value(0).toString();
            map["time"] = query.value(1).toInt();
            list.append(map);
        }
    }
    return list;
}
QVariantList DatabaseManager::getDailyTrends(int daysBack)
{
    QVariantList list;
    QSqlQuery query(m_db);
    // Get total duration per day for the last N days
    query.prepare("SELECT date_str, SUM(total_duration) as total "
                  "FROM daily_summaries "
                  "WHERE date_str >= date('now', :modifier) "
                  "GROUP BY date_str "
                  "ORDER BY date_str ASC");
    QString modifier = QString("-%1 days").arg(daysBack);
    query.bindValue(":modifier", modifier);
    
    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["date"] = query.value(0).toString();
            map["total_time"] = query.value(1).toInt();
            list.append(map);
        }
    } else {
        qDebug() << "Failed to fetch daily trends:" << query.lastError();
    }
    return list;
}

QVariantList DatabaseManager::getUiTopApps(const QString &filter, int limit)
{
    QDateTime now = QDateTime::currentDateTime();
    QVariantList list;
    if (filter == "Daily") {
        QString dateStr = now.toString("yyyy-MM-dd");
        list = getDailySummary(dateStr);
    } else if (filter == "Weekly") {
        list = getWeeklySummary(now.date().year(), now.date().weekNumber());
    } else if (filter == "Monthly") {
        list = getMonthlySummary(now.date().year(), now.date().month());
    }
    
    // Slice manually if list is longer than limit
    while (list.size() > limit) {
        list.removeLast();
    }
    return list;
}

QVariantList DatabaseManager::getUiTrends(const QString &filter)
{
    // For simplicity, regardless of filter we currently return daily trends covering 7 days
    if (filter == "Daily") {
        return getDailyTrends(7);
    } else if (filter == "Weekly") {
        // Just return 14 days for week focus
        return getDailyTrends(14);
    } else {
        // Return 30 days for month focus
        return getDailyTrends(30);
    }
}
