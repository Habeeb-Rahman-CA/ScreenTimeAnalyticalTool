#ifndef USAGETRACKER_H
#define USAGETRACKER_H

#include <QObject>
#include <QTimer>
#include <QString>
#include <QVariantMap>
#include "databasemanager.h"

class UsageTracker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString activeApp READ activeApp NOTIFY activeAppChanged)
    Q_PROPERTY(QString activeTitle READ activeTitle NOTIFY activeTitleChanged)
    Q_PROPERTY(long long totalScreenTime READ totalScreenTime NOTIFY totalScreenTimeChanged)

    Q_PROPERTY(QVariantMap appUsage READ appUsage NOTIFY appUsageChanged)
    Q_PROPERTY(bool isUserIdle READ isUserIdle NOTIFY isUserIdleChanged)
    Q_PROPERTY(DatabaseManager* dbManager READ dbManager CONSTANT)

public:
    explicit UsageTracker(DatabaseManager* db, QObject *parent = nullptr);
    
    DatabaseManager* dbManager() const;

    QString activeApp() const;
    QString activeTitle() const;
    long long totalScreenTime() const;
    QVariantMap appUsage() const;
    bool isUserIdle() const;

signals:
    void activeAppChanged();
    void activeTitleChanged();
    void totalScreenTimeChanged();
    void appUsageChanged();
    void isUserIdleChanged();

private slots:
    void updateTracking();

private:
    QString m_activeApp;
    QString m_activeTitle;
    long long m_totalScreenTime; // in seconds
    QTimer *m_timer;
    
    QMap<QString, long long> m_appUsage;
    bool m_isUserIdle;
    unsigned int m_idleThreshold;
    
    DatabaseManager* m_dbManager;
    int m_currentAppDuration;

    QString getActiveProcessName();
    QString getActiveWindowTitle();
};

#endif // USAGETRACKER_H
