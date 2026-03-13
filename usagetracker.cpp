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

void UsageTracker::updateTracking()
{
    QString currentApp = getActiveProcessName();
    QString currentTitle = getActiveWindowTitle();

    if (currentApp != m_activeApp) {
        m_activeApp = currentApp;
        emit activeAppChanged();
    }

    if (currentTitle != m_activeTitle) {
        m_activeTitle = currentTitle;
        emit activeTitleChanged();
    }

    // Increment total screen time (simple logic for now)
    m_totalScreenTime++;
    emit totalScreenTimeChanged();
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
