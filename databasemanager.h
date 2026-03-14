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

private:
    QSqlDatabase m_db;
    void createTables();
    
    void updateDailySummary(const QString &dateStr, const QString &appName, int durationSeconds);
    void updateWeeklySummary(int year, int week, const QString &appName, int durationSeconds);
    void updateMonthlySummary(int year, int month, const QString &appName, int durationSeconds);
};

#endif // DATABASEMANAGER_H
