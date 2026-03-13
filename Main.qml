import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import ScreenTimeAnalyticalTool

Window {
    id: root
    width: 1100
    height: 750
    visible: true
    title: qsTr("Screen Time Analytical Tool")
    color: Style.backgroundColor

    // Background Gradient Glows
    Rectangle {
        id: bgGlow1
        width: 600; height: 600
        radius: 300
        x: -100; y: -100
        color: Style.accentPurple
        opacity: 0.15
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: 64
        }
    }

    Rectangle {
        id: bgGlow2
        width: 500; height: 500
        radius: 250
        x: root.width - 300; y: root.height - 300
        color: Style.accentBlue
        opacity: 0.1
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: 64
        }
    }

    Row {
        anchors.fill: parent

        // Sidebar
        Rectangle {
            id: sidebar
            width: Style.sidebarWidth
            height: parent.height
            color: Style.glassColor
            border.color: Style.glassBorder
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: Style.paddingLarge
                spacing: 32

                // Logo/Title
                Text {
                    text: "S C R E E N"
                    color: Style.textPrimary
                    font.pixelSize: 22
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                }

                // Nav Items
                Column {
                    width: parent.width - 48
                    spacing: 8

                    NavItem { navText: "Dashboard"; active: true; navIcon: "📊" }
                    NavItem { navText: "App Usage"; navIcon: "💻" }
                    NavItem { navText: "Time Limits"; navIcon: "⏳" }
                    NavItem { navText: "History"; navIcon: "📅" }
                    NavItem { navText: "Settings"; navIcon: "⚙️" }
                }
            }
        }

        // Main Content Area
        Item {
            width: parent.width - sidebar.width
            height: parent.height

            Column {
                anchors.fill: parent
                anchors.margins: Style.paddingLarge
                spacing: 24

                // Header
                Row {
                    width: parent.width
                    height: 60
                    
                    Column {
                        spacing: 4
                        Text {
                            text: "Dashboard Overview"
                            color: Style.textPrimary
                            font.pixelSize: 28
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: "Tracking your digital well-being today"
                            color: Style.textSecondary
                            font.pixelSize: 14
                        }
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
                            let totalSeconds = usageTracker.totalScreenTime
                            let hours = Math.floor(totalSeconds / 3600)
                            let minutes = Math.floor((totalSeconds % 3600) / 60)
                            let seconds = totalSeconds % 60
                            return hours + "h " + minutes + "m " + seconds + "s"
                        }
                        cardSubValue: "Tracking active window"
                        cardIcon: "⏱️"
                        cardAccent: Style.accentPurple
                        width: (parent.width - 40) / 3
                    }

                    StatCard {
                        cardTitle: "Active Application"
                        cardValue: usageTracker.activeApp
                        cardSubValue: usageTracker.activeTitle.substring(0, 30) + (usageTracker.activeTitle.length > 30 ? "..." : "")
                        cardIcon: "💻"
                        cardAccent: Style.accentBlue
                        width: (parent.width - 40) / 3
                    }

                    StatCard {
                        cardTitle: "Focus Score"
                        cardValue: "82"
                        cardSubValue: "Great progress!"
                        cardIcon: "🎯"
                        cardAccent: "#4ADE80"
                        width: (parent.width - 40) / 3
                    }
                }

                // Main Section Grid
                Row {
                    width: parent.width
                    height: 400
                    spacing: 20

                    // Left Column: Usage Chart Placeholder
                    Rectangle {
                        width: (parent.width - 20) * 0.65
                        height: parent.height
                        radius: Style.cardRadius
                        color: Style.glassColor
                        border.color: Style.glassBorder
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Usage Analytics Chart Placeholder"
                            color: Style.textDim
                        }
                    }

                    // Right Column: Top Apps Area
                    Rectangle {
                        width: (parent.width - 20) * 0.35
                        height: parent.height
                        radius: Style.cardRadius
                        color: Style.glassColor
                        border.color: Style.glassBorder
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 16
                            
                            Text {
                                text: "Top Applications"
                                color: Style.textPrimary
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }

                            Column {
                                width: parent.width
                                spacing: 12
                                
                                AppUsageItem { appName: "Visual Studio Code"; appTime: "2h 15m"; appIcon: "🟦" }
                                AppUsageItem { appName: "Google Chrome"; appTime: "1h 30m"; appIcon: "🌐" }
                                AppUsageItem { appName: "Slack"; appTime: "45m"; appIcon: "💬" }
                                AppUsageItem { appName: "Spotify"; appTime: "30m"; appIcon: "🎵" }
                            }
                        }
                    }
                }
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
        height: 44
        radius: 10
        color: active ? "rgba(255, 255, 255, 0.08)" : "transparent"
        
        Row {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -10
            spacing: 12
            Text { text: navRoot.navIcon; font.pixelSize: 18 }
            Text {
                text: navRoot.navText
                color: navRoot.active ? Style.textPrimary : Style.textSecondary
                font.pixelSize: 15
                font.weight: navRoot.active ? Font.Medium : Font.Normal
            }
        }
    }

    component StatCard: Rectangle {
        id: cardRoot
        property string cardTitle: ""
        property string cardValue: ""
        property string cardSubValue: ""
        property string cardIcon: ""
        property color cardAccent: Style.accentPurple
        
        height: parent.height
        radius: Style.cardRadius
        color: Style.glassColor
        border.color: Style.glassBorder

        Rectangle {
            width: 4; height: 40
            radius: 2
            color: cardAccent
            anchors.left: cardRoot.left
            anchors.leftMargin: 16
            anchors.verticalCenter: cardRoot.verticalCenter
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            anchors.leftMargin: 32
            spacing: 4
            
            Text { text: cardRoot.cardTitle; color: Style.textSecondary; font.pixelSize: 13 }
            Text { text: cardRoot.cardValue; color: Style.textPrimary; font.pixelSize: 32; font.weight: Font.Bold }
            Text { text: cardRoot.cardSubValue; color: cardRoot.cardAccent; font.pixelSize: 12 }
        }
        
        Text {
            text: cardRoot.cardIcon
            anchors.right: cardRoot.right
            anchors.top: cardRoot.top
            anchors.margins: 20
            font.pixelSize: 24
            opacity: 0.5
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
        
        Text { text: usageRoot.appIcon; font.pixelSize: 20; anchors.verticalCenter: usageRoot.verticalCenter }
        
        Column {
            anchors.verticalCenter: usageRoot.verticalCenter
            spacing: 2
            Text { text: usageRoot.appName; color: Style.textPrimary; font.pixelSize: 14; font.weight: Font.Medium }
            Rectangle {
                width: 150; height: 4; radius: 2; color: "rgba(255,255,255,0.1)"
                Rectangle {
                    width: parent.width * 0.6; height: 4; radius: 2; color: Style.accentBlue
                }
            }
        }
        
        Item { width: 10; height: 1 } // Spacer
        
        Text {
            anchors.verticalCenter: usageRoot.verticalCenter
            text: usageRoot.appTime
            color: Style.textSecondary
            font.pixelSize: 12
        }
    }
}
