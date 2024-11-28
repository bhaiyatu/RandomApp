import SwiftUI

enum Theme {
    // Primary Colors
    static let primaryColor = Color(hex: "6366F1") // Indigo
    static let secondaryColor = Color(hex: "F3F4F6")
    static let successColor = Color(hex: "10B981") // Emerald
    static let accentColor = Color(hex: "F59E0B") // Amber
    static let dangerColor = Color(hex: "EF4444") // Red
    
    // Text Colors
    static let textColor = Color(hex: "1F2937")
    static let subtleText = Color(hex: "6B7280")
    
    // Background Colors
    static let cardBackground = Color.white
    static let background = Color(hex: "F9FAFB")
    
    // Gradient Colors
    static let gradientStart = Color(hex: "6366F1")
    static let gradientEnd = Color(hex: "8B5CF6")
    
    // Metrics
    static let padding = 16.0
    static let cornerRadius = 16.0
    
    // Shadows
    static let shadowColor = Color.black.opacity(0.1)
    static let shadowRadius = 10.0
    static let shadowY = 4.0
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [gradientStart, gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 