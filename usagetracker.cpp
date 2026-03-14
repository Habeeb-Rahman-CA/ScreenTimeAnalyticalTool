#include "usagetracker.h"
#include <windows.h>
#include <psapi.h>
#include <QDebug>
#include <QFileInfo>

UsageTracker::UsageTracker(DatabaseManager* db, QObject *parent)
    : QObject(parent)
    , m_activeApp("None")
    , m_activeTitle("")
    , m_totalScreenTime(0)
    , m_isUserIdle(false)
    , m_idleThreshold(60000) // 60 seconds
    , m_dbManager(db)
    , m_currentAppDuration(0)
    , m_sessionDuration(0)
{
    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &UsageTracker::updateTracking);
    m_timer->start(1000); // Update every second
}

DatabaseManager* UsageTracker::dbManager() const
{
    return m_dbManager;
}

QString UsageTracker::activeApp() const
{
    return m_activeApp;
}

QString UsageTracker::activeTitle() const
{
    return m_activeTitle;
}

long long UsageTracker::totalScreenTime() const
{
    return m_totalScreenTime;
}

QVariantMap UsageTracker::appUsage() const
{
    QVariantMap map;
    for (auto it = m_appUsage.begin(); it != m_appUsage.end(); ++it) {
        map.insert(it.key(), QVariant::fromValue(it.value()));
    }
    return map;
}

bool UsageTracker::isUserIdle() const
{
    return m_isUserIdle;
}

void UsageTracker::updateTracking()
{
    // Check for idle time
    LASTINPUTINFO lii;
    lii.cbSize = sizeof(LASTINPUTINFO);
    bool currentlyIdle = false;
    
    if (GetLastInputInfo(&lii)) {
        DWORD currentTick = GetTickCount();
        DWORD idleMs = currentTick - lii.dwTime;
        if (idleMs >= m_idleThreshold) {
            currentlyIdle = true;
        }
    }

    if (currentlyIdle != m_isUserIdle) {
        m_isUserIdle = currentlyIdle;
        emit isUserIdleChanged();
    }

    QString currentApp = getActiveProcessName();
    QString currentTitle = getActiveWindowTitle();

    // System sleep / Lock Screen can also be mapped to LogonUI.exe or LockApp.exe
    if (currentApp == "LogonUI.exe" || currentApp == "LockApp.exe") {
        currentlyIdle = true; // explicitly treat lock screen as idle
    }

    if (currentlyIdle) {
        currentApp = "Idle";
        currentTitle = "";
        m_sessionDuration = 0; // Reset session on idle
    }

    if (currentApp != m_activeApp) {
        if (m_currentAppDuration > 0 && m_dbManager) {
            m_dbManager->logAppUsage(m_activeApp, m_currentAppDuration);
            m_currentAppDuration = 0;
        }
        m_activeApp = currentApp;
        emit activeAppChanged();
    }

    if (currentTitle != m_activeTitle) {
        m_activeTitle = currentTitle;
        emit activeTitleChanged();
    }

    if (!currentlyIdle) {
        m_totalScreenTime++;
        m_currentAppDuration++;
        m_sessionDuration++;
        
        if (m_currentAppDuration >= 60 && m_dbManager) {
            m_dbManager->logAppUsage(m_activeApp, m_currentAppDuration);
            m_currentAppDuration = 0;
        }
        
        emit totalScreenTimeChanged();
        
        m_appUsage[m_activeApp]++;
        emit appUsageChanged();

        // Phase 4: Limit Checking
        if (m_dbManager) {
            // 0. Break Reminder (Total continuous session)
            if (m_dbManager->checkLimit("Break", m_sessionDuration, "Session")) {
                emit limitReached("<b>Time for a break!</b><br>You've been active for 45 minutes straight. Stand up and stretch.", "Break", false);
            }

            // 1. Check App Daily Limit
            if (m_dbManager->checkLimit(m_activeApp, m_appUsage[m_activeApp])) {
                emit limitReached("<b>Daily Limit Reached</b><br>You've used " + m_activeApp + " for its allotted time today.", "Daily", false);
            }

            // 1b. Check App Weekly Limit
            if (m_dbManager->checkLimit(m_activeApp, 0, "Weekly")) {
                emit limitReached("<b>Weekly Limit Reached</b><br>" + m_activeApp + " has exceeded its weekly quota.", "Weekly", false);
            }

            // 2. Check Session Limit (Current continuous usage)
            if (m_dbManager->checkLimit(m_activeApp, m_currentAppDuration, "Session")) {
                emit limitReached("<b>Session Limit Reached</b><br>Focus session for " + m_activeApp + " has ended.", "Session", false);
            }

            // 3. Website Limits
            bool isBrowser = m_activeApp.toLower().contains("chrome") || 
                            m_activeApp.toLower().contains("edge") || 
                            m_activeApp.toLower().contains("firefox") || 
                            m_activeApp.toLower().contains("browser");
            
            if (isBrowser && !m_activeTitle.isEmpty()) {
                QString site = m_activeTitle;
                if (site.contains(" - ")) site = site.split(" - ").at(0);
                else if (site.contains(" — ")) site = site.split(" — ").at(0);
                site = site.trimmed();

                if (m_dbManager->checkLimit(site, m_appUsage[site], "Daily")) {
                    emit limitReached("<b>Website Limit</b><br>" + site + " usage has reached your daily limit.", "Daily", true);
                }
            }
        }
    }
}

QString UsageTracker::getActiveProcessName()
{
    HWND hwnd = GetForegroundWindow();
    if (!hwnd) return "Idle";

    DWORD processId;
    GetWindowThreadProcessId(hwnd, &processId);

    HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processId);
    if (!hProcess) return "System";

    WCHAR buffer[MAX_PATH];
    if (GetModuleFileNameExW(hProcess, NULL, buffer, MAX_PATH)) {
        CloseHandle(hProcess);
        return QFileInfo(QString::fromWCharArray(buffer)).fileName();
    }

    CloseHandle(hProcess);
    return "Unknown";
}

QString UsageTracker::getActiveWindowTitle()
{
    HWND hwnd = GetForegroundWindow();
    if (!hwnd) return "";

    int length = GetWindowTextLengthW(hwnd);
    if (length == 0) return "";

    WCHAR* buffer = new WCHAR[length + 1];
    GetWindowTextW(hwnd, buffer, length + 1);
    QString title = QString::fromWCharArray(buffer);
    delete[] buffer;

    return title;
}
