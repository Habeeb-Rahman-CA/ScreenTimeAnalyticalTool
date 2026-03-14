#include "usagetracker.h"
#include <windows.h>
#include <psapi.h>
#include <QDebug>
#include <QFileInfo>

UsageTracker::UsageTracker(QObject *parent)
    : QObject(parent)
    , m_activeApp("None")
    , m_activeTitle("")
    , m_totalScreenTime(0)
    , m_isUserIdle(false)
    , m_idleThreshold(60000) // 60 seconds
{
    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &UsageTracker::updateTracking);
    m_timer->start(1000); // Update every second
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
    }

    if (currentApp != m_activeApp) {
        m_activeApp = currentApp;
        emit activeAppChanged();
    }

    if (currentTitle != m_activeTitle) {
        m_activeTitle = currentTitle;
        emit activeTitleChanged();
    }

    if (!currentlyIdle) {
        m_totalScreenTime++;
        emit totalScreenTimeChanged();
        
        m_appUsage[m_activeApp]++;
        emit appUsageChanged(); // Potentially heavy if many apps, but acceptable for MVP
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
