import QtQuick

pragma Singleton

QtObject {
    // Primary Colors
    readonly property color backgroundColor: "#0F0F12"
    readonly property color surfaceColor: "#1A1A1E"
    readonly property color glassColor: "rgba(255, 255, 255, 0.05)"
    readonly property color glassBorder: "rgba(255, 255, 255, 0.1)"
    
    // Accents
    readonly property color accentPurple: "#8A2BE2"
    readonly property color accentBlue: "#00CED1"
    readonly property color accentGradientStart: "#6366F1"
    readonly property color accentGradientEnd: "#A855F7"
    
    // Text
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#A0A0A0"
    readonly property color textDim: "#606060"
    
    // Dimensions
    readonly property int sidebarWidth: 240
    readonly property int cardRadius: 16
    readonly property int paddingMedium: 16
    readonly property int paddingLarge: 24
    
    // Fonts
    readonly property string mainFont: "Inter" // Fallback to system
}
