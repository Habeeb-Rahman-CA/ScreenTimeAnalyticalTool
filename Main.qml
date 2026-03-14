import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt.labs.platform as Platform
import QtCharts
import ScreenTimeAnalyticalTool

pragma ComponentBehavior: Bound

Window {
    id: root
    width: 1200
    height: 800
    minimumWidth: 1000
    minimumHeight: 700
    visible: true
    title: qsTr("Screen Time Analytical Tool")
    color: AppStyle.backgroundColor

    property string currentFilter: "Daily"

    ListModel { id: topAppsModel }

    Component.onCompleted: {
        console.log("Dashboard UI Initialized");
        root.refreshData();
    }

    Platform.SystemTrayIcon {
        visible: true
        tooltip: "Screen Time Tool - " + Math.floor(usageTracker.totalScreenTime / 60) + " min tracked"
        menu: Platform.Menu {
            Platform.MenuItem {
                text: "Open Dashboard"
                onTriggered: root.show()
            }
            Platform.MenuItem {
                text: "Quit"
                onTriggered: root.close()
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: AppStyle.sidebarWidth
            color: AppStyle.backgroundColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppStyle.paddingLarge
                spacing: 40

                // Logo/Title
                Row {
                    spacing: 12
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 12
                        color: AppStyle.accentLime
                        Text {
                            text: "S"
                            anchors.centerIn: parent
                            font.bold: true
                            font.pixelSize: 20
                            color: "#000"
                        }
                    }
                    Text {
                        text: "Deliro"
                        color: AppStyle.textPrimary
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    text: "MENU"
                    color: AppStyle.textDim
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 1.5
                }

                // Nav Items
                Column {
                    Layout.fillWidth: true
                    spacing: 6

                    NavItem {
                        navText: "Dashboard"
                        active: true
                        navIcon: "ic_dashboard.svg"
                    }
                    NavItem {
                        navText: "Settings"
                        navIcon: "ic_settings.svg"
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
        }

        // Main Content Area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                id: contentScroll
                anchors.fill: parent
                contentWidth: availableWidth
                clip: true

                ColumnLayout {
                    width: contentScroll.availableWidth
                    anchors.margins: AppStyle.paddingLarge
                    spacing: 24
                    
                    Item { height: 16 } // Top margin

                    // Top Header Row
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 32
                        Layout.rightMargin: 32

                        Column {
                            Layout.fillWidth: true
                            Text {
                                text: "Visual Analytics"
                                color: AppStyle.textPrimary
                                font.pixelSize: 32
                                font.weight: Font.Bold
                            }
                            Text {
                                text: "Insights into your screen time behavior"
                                color: AppStyle.textSecondary
                                font.pixelSize: 14
                            }
                        }
                    }

                    // Stats Cards Row
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 32
                        Layout.rightMargin: 32
                        spacing: 20

                        StatCard {
                            Layout.fillWidth: true
                            cardTitle: "Total Screen Time"
                            cardValue: root.formatTime(usageTracker.totalScreenTime)
                            cardSubValue: "Tracking since boot"
                            cardIcon: "ic_time.svg"
                            cardAccent: AppStyle.accentLime
                            showProgress: true
                            progressValue: 0.7
                        }

                        StatCard {
                            Layout.fillWidth: true
                            cardTitle: "Most Used App"
                            cardValue: topAppsModel.count > 0 ? topAppsModel.get(0).name : "N/A"
                            cardSubValue: topAppsModel.count > 0 ? root.formatTime(topAppsModel.get(0).time) : "0m"
                            cardIcon: "ic_apps.svg"
                            cardAccent: AppStyle.accentBlue
                        }

                        StatCard {
                            Layout.fillWidth: true
                            cardTitle: "Active Now"
                            cardValue: usageTracker.activeApp !== "Idle" ? usageTracker.activeApp : "Idle"
                            cardSubValue: usageTracker.activeTitle
                            cardIcon: "ic_target.svg"
                            cardAccent: AppStyle.accentOrange
                        }
                    }

                    // Analytics Charts Section
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 32
                        Layout.rightMargin: 32
                        columns: width < 900 ? 1 : 2
                        rowSpacing: 24
                        columnSpacing: 24

                        // Line Chart: Usage Trends with Integrated Filter
                        ChartContainer {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 350
                            chartTitle: "Screen Time Trends"
                            
                            // Integrated Filter Switch
                            Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 16
                                height: 36
                                radius: 8
                                color: "#0DFFFFFF"
                                border.color: "#11FFFFFF"
                                z: 20
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    padding: 2
                                    Repeater {
                                        model: ["Daily", "Weekly", "Monthly"]
                                        Rectangle {
                                            id: filterBtn
                                            required property string modelData
                                            width: 70
                                            height: 32
                                            radius: 6
                                            color: root.currentFilter === filterBtn.modelData ? AppStyle.accentLime : "transparent"
                                            Text {
                                                text: filterBtn.modelData
                                                anchors.centerIn: parent
                                                color: root.currentFilter === filterBtn.modelData ? "#000" : AppStyle.textSecondary
                                                font.pixelSize: 11
                                                font.bold: root.currentFilter === filterBtn.modelData
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    root.currentFilter = filterBtn.modelData;
                                                    root.refreshData();
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            ChartView {
                                id: trendChart
                                anchors.fill: parent
                                anchors.topMargin: 40
                                backgroundColor: "transparent"
                                legend.visible: false
                                antialiasing: true

                                LineSeries {
                                    id: trendSeries
                                    name: "Minutes"
                                    color: AppStyle.accentLime
                                    width: 3
                                    axisX: ValueAxis {
                                        id: axisX
                                        gridLineColor: "#11FFFFFF"
                                        labelsColor: AppStyle.textSecondary
                                        labelFormat: "%.0f"
                                    }
                                    axisY: ValueAxis {
                                        id: axisY
                                        gridLineColor: "#11FFFFFF"
                                        labelsColor: AppStyle.textSecondary
                                        labelFormat: "%.0f"
                                        titleText: "Minutes"
                                    }
                                }
                            }
                        }

                        // Pie Chart: Usage Distribution
                        ChartContainer {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 350
                            chartTitle: "App Distribution (%)"
                            
                            ChartView {
                                id: distChart
                                anchors.fill: parent
                                anchors.topMargin: 20
                                backgroundColor: "transparent"
                                legend.visible: true
                                legend.alignment: Qt.AlignRight
                                legend.labelColor: AppStyle.textSecondary
                                legend.font.pixelSize: 10
                                antialiasing: true

                                PieSeries {
                                    id: pieSeries
                                    holeSize: 0.5
                                }
                            }
                        }

                        // Bar Chart: Top Applications
                        ChartContainer {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 350
                            chartTitle: "Top Used Time (Seconds)"

                            ChartView {
                                id: barChart
                                anchors.fill: parent
                                anchors.topMargin: 40
                                backgroundColor: "transparent"
                                legend.visible: false
                                antialiasing: true

                                BarSeries {
                                    id: topAppsBarSeries
                                    axisX: BarCategoryAxis { 
                                        id: barAxisX
                                        labelsColor: AppStyle.textSecondary
                                        gridLineColor: "transparent"
                                    }
                                    axisY: ValueAxis {
                                        id: barAxisY
                                        labelsColor: AppStyle.textSecondary
                                        gridLineColor: "#11FFFFFF"
                                    }
                                    BarSet {
                                        id: topAppsBarSet
                                        color: AppStyle.accentBlue
                                        borderColor: "transparent"
                                    }
                                }
                            }
                        }

                        // Ranking Table
                        ChartContainer {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 350
                            chartTitle: "App Rankings"

                            ListView {
                                id: topAppsList
                                anchors.fill: parent
                                anchors.topMargin: 50
                                anchors.bottomMargin: 20
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                spacing: 8
                                model: topAppsModel
                                delegate: AppUsageItem {
                                    required property string name
                                    required property int time
                                    required property int index
                                    
                                    width: topAppsList.width
                                    appName: name
                                    appTime: root.formatTime(time)
                                    appIcon: "ic_apps.svg"
                                    rank: index + 1
                                    percentage: usageTracker.totalScreenTime > 0 ? (time / usageTracker.totalScreenTime) * 100 : 0
                                }
                                clip: true
                            }
                        }
                    }
                    
                    Item { height: 32 } // Bottom margin
                }
            }
        }
    }

    function formatTime(totalSeconds) {
        if (totalSeconds <= 0) return "0s";
        let hours = Math.floor(totalSeconds / 3600);
        let minutes = Math.floor((totalSeconds % 3600) / 60);
        let seconds = totalSeconds % 60;
        
        if (hours > 0) return hours + "h " + minutes + "m";
        if (minutes > 0) return minutes + "m " + seconds + "s";
        return seconds + "s";
    }

    function refreshData() {
        if (!dbManager) return;
        
        // 1. Refresh Top Apps (List, Pie, Bar)
        let topApps = dbManager.getUiTopApps(currentFilter, 6);
        topAppsModel.clear();
        pieSeries.clear();
        
        let barCategories = [];
        let barValues = [];

        for (let i = 0; i < topApps.length; i++) {
            topAppsModel.append(topApps[i]);
            let slice = pieSeries.append(topApps[i].name, topApps[i].time);
            slice.labelVisible = i < 3;
            slice.label = topApps[i].name + " (" + Math.round((topApps[i].time / usageTracker.totalScreenTime) * 100) + "%)";
            
            barCategories.push(topApps[i].name.substring(0, 10)); // Truncate long names for axis
            barValues.push(topApps[i].time);
        }

        // Update Bar Chart
        barAxisX.categories = barCategories;
        topAppsBarSet.values = barValues;
        
        let maxBarVal = 0;
        for (let val of barValues) if (val > maxBarVal) maxBarVal = val;
        barAxisY.max = maxBarVal > 0 ? maxBarVal * 1.1 : 3600;

        // 2. Refresh Trends (Line Chart)
        let trends = dbManager.getUiTrends(currentFilter);
        trendSeries.clear();
        let maxVal = 0;
        for (let i = 0; i < trends.length; i++) {
            let val = trends[i].total_time / 60; // In minutes
            trendSeries.append(i, val);
            if (val > maxVal) maxVal = val;
        }
        axisX.max = trends.length > 1 ? trends.length - 1 : 1;
        axisX.min = 0;
        axisX.tickCount = Math.min(trends.length, 10);
        axisY.max = maxVal > 0 ? maxVal * 1.2 : 60;
        axisY.min = 0;
    }

    Connections {
        target: usageTracker
        function onTotalScreenTimeChanged() {
            if (usageTracker.totalScreenTime % 10 === 0) {
                root.refreshData();
            }
        }
    }

    // --- Components ---

    component ChartContainer: Rectangle {
        id: container
        property string chartTitle: ""
        radius: AppStyle.cardRadius
        color: AppStyle.surfaceColor
        border.color: AppStyle.cardBorder
        border.width: 1
        
        Text {
            text: container.chartTitle
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 16
            color: AppStyle.accentLime
            font.pixelSize: 14
            font.weight: Font.Bold
            z: 10
        }
    }

    component NavItem: Rectangle {
        id: navRoot
        property string navText: ""
        property string navIcon: ""
        property bool active: false

        width: parent.width
        height: 50
        radius: 12
        color: navRoot.active ? "#1A1A1A" : "transparent"

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            spacing: 12

            Rectangle {
                width: 32
                height: 32
                radius: 10
                color: navRoot.active ? AppStyle.accentLime : "transparent"
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    source: navRoot.navIcon
                    width: 16
                    height: 16
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    opacity: navRoot.active ? 1.0 : 0.5
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
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: if(!navRoot.active) navRoot.color = "#0DFFFFFF"
            onExited: if(!navRoot.active) navRoot.color = "transparent"
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
        property real progressValue: 0.0

        height: 140
        radius: AppStyle.cardRadius
        color: AppStyle.surfaceColor
        border.color: AppStyle.cardBorder
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 8

            RowLayout {
                width: parent.width
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: "#0DFFFFFF"
                    Image {
                        source: cardRoot.cardIcon
                        width: 14
                        height: 14
                        anchors.centerIn: parent
                        opacity: 0.8
                        fillMode: Image.PreserveAspectFit
                    }
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: cardRoot.cardTitle
                    color: AppStyle.textSecondary
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }

            Text {
                text: cardRoot.cardValue
                color: AppStyle.textPrimary
                font.pixelSize: 22
                font.weight: Font.Bold
                width: parent.width
                elide: Text.ElideRight
            }

            Rectangle {
                visible: cardRoot.showProgress
                width: parent.width
                height: 4
                radius: 2
                color: "#1AFFFFFF"
                Rectangle {
                    width: parent.width * cardRoot.progressValue
                    height: 4
                    radius: 2
                    color: cardRoot.cardAccent
                }
            }

            Text {
                text: cardRoot.cardSubValue
                color: AppStyle.textDim
                font.pixelSize: 11
                width: parent.width
                elide: Text.ElideRight
            }
        }
    }

    component AppUsageItem: Item {
        id: usageRoot
        property string appName: ""
        property string appTime: ""
        property string appIcon: "ic_apps.svg"
        property int rank: 1
        property real percentage: 0.0

        width: parent.width
        height: 46

        RowLayout {
            anchors.fill: parent
            spacing: 12

            Text {
                text: usageRoot.rank
                color: AppStyle.textDim
                font.pixelSize: 13
                font.weight: Font.Bold
                Layout.preferredWidth: 15
            }

            Rectangle {
                width: 32
                height: 32
                radius: 8
                color: "#0DFFFFFF"
                Image {
                    source: usageRoot.appIcon
                    width: 16
                    height: 16
                    anchors.centerIn: parent
                    opacity: 0.8
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: usageRoot.appName
                    color: AppStyle.textPrimary
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 3
                    radius: 1.5
                    color: "#0DFFFFFF"
                    Rectangle {
                        width: parent.width * (usageRoot.percentage / 100)
                        height: 3
                        radius: 1.5
                        color: AppStyle.accentBlue
                    }
                }
            }

            Text {
                text: usageRoot.appTime
                color: AppStyle.textSecondary
                font.pixelSize: 11
                font.weight: Font.Bold
                Layout.preferredWidth: 60
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
