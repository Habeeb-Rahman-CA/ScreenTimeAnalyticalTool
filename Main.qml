import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt.labs.platform as Platform
import QtCharts
import ScreenTimeAnalyticalTool

Window {
    id: root
    width: 1100
    height: 750
    visible: true
    title: qsTr("Screen Time Analytical Tool")
    color: (AppStyle && AppStyle.backgroundColor) ? AppStyle.backgroundColor : "#111111"

    property string currentFilter: "Daily"

    Component.onCompleted: {
        console.log("Root Window Completed");
        if (typeof AppStyle !== "undefined") {
            console.log("AppStyle found:", AppStyle.backgroundColor);
        } else {
            console.warn("AppStyle NOT FOUND");
        }
        refreshData();
    }

    Platform.SystemTrayIcon {
        visible: true
        tooltip: "Screen Time Tool - " + Math.floor(usageTracker.totalScreenTime / 60) + " min tracked"
        menu: Platform.Menu {
            Platform.MenuItem {
                text: "Quit"
                onTriggered: Qt.quit()
            }
        }
    }

    Row {
        anchors.fill: parent

        // Sidebar
        Rectangle {
            id: sidebar
            width: AppStyle.sidebarWidth
            height: parent.height
            color: AppStyle.backgroundColor

            Column {
                anchors.fill: parent
                anchors.margins: AppStyle.paddingLarge
                spacing: 32

                // Logo/Title
                Row {
                    Text {
                        text: "Deliro"
                        color: AppStyle.textPrimary
                        font.pixelSize: 22
                        font.weight: Font.Bold
                    }
                }

                Text {
                    text: "Navigation"
                    color: AppStyle.textDim
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                }

                // Nav Items
                Column {
                    width: parent.width
                    spacing: 8

                    NavItem {
                        navText: "Dashboard"
                        active: true
                        navIcon: "ic_dashboard.svg"
                    }
                    NavItem {
                        navText: "Schedule"
                        navIcon: "ic_time.svg"
                    }
                    NavItem {
                        navText: "Reports & Analytics"
                        navIcon: "ic_history.svg"
                    }
                    NavItem {
                        navText: "Settings"
                        navIcon: "ic_settings.svg"
                    }
                }
            }
        }

        // Main Content Area
        Item {
            id: contentArea
            width: parent.width - sidebar.width
            height: parent.height

            Column {
                anchors.fill: parent
                anchors.margins: AppStyle.paddingLarge
                spacing: 32

                // Top Search Bar & Profile Header
                RowLayout {
                    width: parent.width
                    height: 50
                    spacing: 20

                    Rectangle {
                        width: 400
                        height: 44
                        radius: 22
                        color: AppStyle.surfaceColor
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            spacing: 12
                            Image {
                                source: "ic_search.svg"
                                width: 16
                                height: 16
                                opacity: 0.6
                                anchors.verticalCenter: parent.verticalCenter
                                fillMode: Image.PreserveAspectFit
                            }
                            TextInput {
                                text: "Search here"
                                color: AppStyle.textDim
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 60
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    } // Spacer

                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: AppStyle.surfaceColor
                        Image {
                            source: "ic_bell.svg"
                            width: 20
                            height: 20
                            anchors.centerIn: parent
                            opacity: 0.8
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: AppStyle.surfaceColor
                        Image {
                            source: "ic_user.svg"
                            width: 20
                            height: 20
                            anchors.centerIn: parent
                            opacity: 0.8
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }

                // Welcome Header & Filters
                RowLayout {
                    width: parent.width
                    spacing: 20

                    Column {
                        spacing: 8
                        Layout.fillWidth: true
                        Text {
                            text: "Welcome back"
                            color: AppStyle.textPrimary
                            font.pixelSize: 28
                            font.weight: Font.Bold
                        }
                        Text {
                            text: "Here's your productivity summary"
                            color: AppStyle.textSecondary
                            font.pixelSize: 15
                        }
                    }

                    // Filters
                    Rectangle {
                        height: 40
                        radius: 20
                        color: AppStyle.surfaceColor
                        Row {
                            anchors.centerIn: parent
                            spacing: 4
                            padding: 4

                            Repeater {
                                model: ["Daily", "Weekly", "Monthly"]
                                Rectangle {
                                    width: 80
                                    height: 32
                                    radius: 16
                                    color: root.currentFilter === modelData ? AppStyle.accentLime : "transparent"
                                    Text {
                                        text: modelData
                                        anchors.centerIn: parent
                                        color: root.currentFilter === modelData ? "#000000" : AppStyle.textSecondary
                                        font.pixelSize: 13
                                        font.weight: root.currentFilter === modelData ? Font.Bold : Font.Normal
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            root.currentFilter = modelData;
                                            refreshData();
                                        }
                                    }
                                }
                            }
                        }
                        Layout.preferredWidth: 260
                    }
                }

                // Stats Cards Row
                Row {
                    width: parent.width
                    height: 160
                    spacing: 20

                    StatCard {
                        cardTitle: "Total Screen Time"
                        cardValue: {
                            let totalSeconds = usageTracker.totalScreenTime;
                            let hours = Math.floor(totalSeconds / 3600);
                            let minutes = Math.floor((totalSeconds % 3600) / 60);
                            let seconds = totalSeconds % 60;
                            return hours + "h " + minutes + "m " + seconds + "s";
                        }
                        cardSubValue: "Tracking active window"
                        cardIcon: "ic_time.svg"
                        cardAccent: AppStyle.accentLime
                        width: (parent.width - 20) / 2
                        showProgress: true
                    }

                    StatCard {
                        cardTitle: "Active Application"
                        cardValue: usageTracker.activeApp
                        cardSubValue: usageTracker.activeTitle
                        cardIcon: "ic_apps.svg"
                        cardAccent: AppStyle.accentLime
                        width: (parent.width - 20) / 2
                    }
                }

                // Main Section Grid
                RowLayout {
                    width: parent.width
                    height: contentArea.height - 350
                    spacing: 20

                    // Left Column: Usage Trends Line Chart
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: AppStyle.cardRadius
                        color: AppStyle.surfaceColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12

                            Text {
                                text: root.currentFilter + " Usage Trends"
                                color: AppStyle.textPrimary
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }

                            ChartView {
                                id: trendChart
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                backgroundColor: "transparent"
                                legend.visible: false
                                antialiasing: true

                                LineSeries {
                                    id: trendSeries
                                    name: "Screen Time"
                                    color: AppStyle.accentLime
                                    width: 3
                                    
                                    axisX: ValueAxis {
                                        id: axisX
                                        gridLineColor: "#1AFFFFFF"
                                        labelsColor: AppStyle.textSecondary
                                        labelFormat: "%.0f"
                                    }
                                    axisY: ValueAxis {
                                        id: axisY
                                        gridLineColor: "#1AFFFFFF"
                                        labelsColor: AppStyle.textSecondary
                                        labelFormat: "%.0f"
                                        titleText: "Minutes"
                                    }
                                }
                            }
                        }
                    }

                    // Right Column: Top Applications
                    Rectangle {
                        Layout.preferredWidth: 350
                        Layout.fillHeight: true
                        radius: AppStyle.cardRadius
                        color: AppStyle.surfaceColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 16

                            Text {
                                id: listTitle
                                text: "Top Applications"
                                color: AppStyle.textPrimary
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }

                            ListView {
                                id: topAppsList
                                Layout.fillWidth: true
                                Layout.preferredHeight: 180
                                spacing: 12
                                model: ListModel { id: topAppsModel }
                                delegate: AppUsageItem {
                                    width: topAppsList.width
                                    appName: name
                                    appTime: {
                                        let hours = Math.floor(time / 3600);
                                        let minutes = Math.floor((time % 3600) / 60);
                                        let seconds = time % 60;
                                        if (hours > 0) return hours + "h " + minutes + "m";
                                        if (minutes > 0) return minutes + "m " + seconds + "s";
                                        return seconds + "s";
                                    }
                                    appIcon: "ic_apps.svg"
                                }
                                clip: true
                            }

                            Item { Layout.fillHeight: true }

                            ChartView {
                                id: distChart
                                Layout.fillWidth: true
                                Layout.preferredHeight: 150
                                backgroundColor: "transparent"
                                legend.visible: false
                                antialiasing: true

                                PieSeries {
                                    id: pieSeries
                                    holeSize: 0.5
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function refreshData() {
        if (!dbManager) return;
        
        // 1. Refresh Top Apps and Pie Chart from DB
        let topApps = dbManager.getUiTopApps(currentFilter, 6);
        topAppsModel.clear();
        pieSeries.clear();
        for (let i = 0; i < topApps.length; i++) {
            topAppsModel.append(topApps[i]);
            pieSeries.append(topApps[i].name, topApps[i].time);
        }

        // 2. Refresh Trends from DB
        let trends = dbManager.getUiTrends(currentFilter);
        trendSeries.clear();
        let maxVal = 0;
        for (let i = 0; i < trends.length; i++) {
            let val = trends[i].total_time / 60; // In minutes
            trendSeries.append(i, val);
            if (val > maxVal) maxVal = val;
        }
        axisX.max = trends.length > 1 ? trends.length - 1 : 7;
        axisY.max = maxVal > 0 ? maxVal * 1.2 : 60;
    }



    Connections {
        target: usageTracker
        function onAppUsageChanged() {
            // Live Update: we could refreshData() here, but it might be too frequent.
            // Let's just update the current active session or refresh every minute.
        }
        function onTotalScreenTimeChanged() {
            // Periodically refresh the list and chart to show live progress
            if (usageTracker.totalScreenTime % 30 === 0) {
                refreshData();
            }
        }
    }

    // --- Inner Component Templates ---

    component NavItem: Rectangle {
        id: navRoot
        property string navText: ""
        property string navIcon: ""
        property bool active: false

        width: parent.width
        height: 50
        radius: 12
        color: active ? "#1A1A1A" : "transparent"

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            spacing: 12

            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: navRoot.active ? AppStyle.accentLime : "transparent"
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    source: navRoot.navIcon
                    width: 16
                    height: 16
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    opacity: navRoot.active ? 1.0 : 0.6
                }
            }

            Text {
                text: navRoot.navText
                color: navRoot.active ? AppStyle.textPrimary : AppStyle.textSecondary
                font.pixelSize: 14
                font.weight: navRoot.active ? Font.Bold : Font.Normal
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    component StatCard: Rectangle {
        id: cardRoot
        property string cardTitle: ""
        property string cardValue: ""
        property string cardSubValue: ""
        property string cardIcon: ""
        property color cardAccent: AppStyle.accentPurple
        property bool showProgress: false

        height: parent.height
        radius: AppStyle.cardRadius
        color: AppStyle.surfaceColor

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 12

            RowLayout {
                width: parent.width
                Text {
                    text: cardRoot.cardTitle
                    color: AppStyle.textSecondary
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    Layout.fillWidth: true
                }
                Image {
                    source: cardRoot.cardIcon
                    width: 20
                    height: 20
                    opacity: 0.8
                    fillMode: Image.PreserveAspectFit
                }
            }

            Text {
                text: cardRoot.cardValue
                color: AppStyle.textPrimary
                font.pixelSize: 24
                font.weight: Font.Bold
                width: parent.width
                elide: Text.ElideRight
                clip: true
            }

            Rectangle {
                visible: cardRoot.showProgress
                width: parent.width
                height: 8
                radius: 4
                color: "#0A0A0A"
                Rectangle {
                    width: parent.width * 0.6
                    height: 8
                    radius: 4
                    color: cardRoot.cardAccent
                }
            }

            Text {
                text: cardRoot.cardSubValue
                color: AppStyle.textSecondary
                font.pixelSize: 12
                width: parent.width
                elide: Text.ElideRight
                clip: true
            }
        }
    }

    component AppUsageItem: Row {
        id: usageRoot
        property string appName: ""
        property string appTime: ""
        property string appIcon: ""

        width: parent.width
        height: 40
        spacing: 12

        Image {
            source: usageRoot.appIcon
            width: 20
            height: 20
            anchors.verticalCenter: usageRoot.verticalCenter
            opacity: 0.8
            fillMode: Image.PreserveAspectFit
        }

        Column {
            anchors.verticalCenter: usageRoot.verticalCenter
            spacing: 2
            Text {
                text: usageRoot.appName
                color: AppStyle.textPrimary
                font.pixelSize: 14
                font.weight: Font.Medium
                width: 150
                elide: Text.ElideRight
                clip: true
            }
            Rectangle {
                width: 150
                height: 4
                radius: 2
                color: "#1AFFFFFF"
                Rectangle {
                    width: parent.width * 0.6
                    height: 4
                    radius: 2
                    color: AppStyle.accentBlue
                }
            }
        }

        Item {
            width: 10
            height: 1
        } // Spacer

        Text {
            anchors.verticalCenter: usageRoot.verticalCenter
            text: usageRoot.appTime
            color: AppStyle.textSecondary
            font.pixelSize: 12
        }
    }
}
