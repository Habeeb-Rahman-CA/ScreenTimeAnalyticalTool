import QtQuick

pragma Singleton

QtObject {
    Component.onCompleted: console.log("Style singleton initialized")
    // Primary Colors
    readonly property color backgroundColor: "#080808"
    readonly property color surfaceColor: "#141414"
    readonly property color cardColor: "#141414"
    readonly property color cardBorder: "#1AFFFFFF"

    // Accents (inspired by Prodly)
    readonly property color accentLime: "#B1F24B"
    readonly property color accentOrange: "#FF9F46"
    readonly property color accentGreen: "#4ADE80"
    readonly property color accentYellow: "#FACC15"
    
    // Text
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#8A8A8A"
    readonly property color textDim: "#444444"
    
    // Dimensions
    readonly property int sidebarWidth: 220
    readonly property int cardRadius: 24
    readonly property int paddingMedium: 16
    readonly property int paddingLarge: 32
    
    // Fonts
    readonly property string mainFont: "Segoe UI"
}
