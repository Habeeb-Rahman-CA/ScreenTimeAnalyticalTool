#ifndef USAGETRACKER_H
#define USAGETRACKER_H

#include <QObject>
#include <QTimer>
#include <QString>
#include <QVariantMap>

class UsageTracker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString activeApp READ activeApp NOTIFY activeAppChanged)
    Q_PROPERTY(QString activeTitle READ activeTitle NOTIFY activeTitleChanged)
    Q_PROPERTY(long long totalScreenTime READ totalScreenTime NOTIFY totalScreenTimeChanged)

public:
    explicit UsageTracker(QObject *parent = nullptr);

    QString activeApp() const;
    QString activeTitle() const;
    long long totalScreenTime() const;

signals:
    void activeAppChanged();
    void activeTitleChanged();
    void totalScreenTimeChanged();

private slots:
    void updateTracking();

private:
    QString m_activeApp;
    QString m_activeTitle;
    long long m_totalScreenTime; // in seconds
    QTimer *m_timer;
    
    QString getActiveProcessName();
    QString getActiveWindowTitle();
};

#endif // USAGETRACKER_H
