#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QVariantList>
#include <QString>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    bool initializeDatabase();
    
    Q_INVOKABLE void logAppUsage(const QString &appName, int durationSeconds);
    
    Q_INVOKABLE QVariantList getDailySummary(const QString &dateStr);
    Q_INVOKABLE QVariantList getWeeklySummary(int year, int week);
    Q_INVOKABLE QVariantList getMonthlySummary(int year, int month);
    Q_INVOKABLE QVariantList getDailyTrends(int daysBack);
    
    Q_INVOKABLE QVariantList getUiTopApps(const QString &filter, int limit = 5);
    Q_INVOKABLE QVariantList getUiTrends(const QString &filter);

    // Phase 4: Limits
    Q_INVOKABLE void setAppLimit(const QString &target, int limitSeconds, const QString &limitType = "Daily", bool isWebsite = false);
    Q_INVOKABLE void removeAppLimit(const QString &target);
    Q_INVOKABLE QVariantList getAppLimits();
    Q_INVOKABLE bool checkLimit(const QString &target, int currentUsageSeconds, const QString &limitType = "Daily");

private:
    QSqlDatabase m_db;
    void createTables();
    
    void updateDailySummary(const QString &dateStr, const QString &appName, int durationSeconds);
    void updateWeeklySummary(int year, int week, const QString &appName, int durationSeconds);
    void updateMonthlySummary(int year, int month, const QString &appName, int durationSeconds);
};

#endif // DATABASEMANAGER_H
