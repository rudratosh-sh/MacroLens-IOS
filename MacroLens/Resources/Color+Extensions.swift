//
//  Color+Extensions.swift
//  MacroLens
//
//  Brand colors and design system
//

import SwiftUI

extension Color {
    
    // MARK: - Brand Colors
    
    /// Primary gradient start - Deep teal #007B83
    static let primaryStart = Color(hex: "007B83")
    
    /// Primary gradient end - Aqua #00BFA6
    static let primaryEnd = Color(hex: "00BFA6")
    
    /// Secondary - Leaf green #6CCB7E
    static let secondary = Color(hex: "6CCB7E")
    
    /// Accent - Mint #A3E4D7
    static let accent = Color(hex: "A3E4D7")
    
    // MARK: - Text Colors
    
    /// Primary text - Dark teal-gray #1A2E2B
    static let textPrimary = Color(hex: "1A2E2B")
    
    /// Secondary text - Medium teal-gray #587072
    static let textSecondary = Color(hex: "587072")
    
    /// Tertiary text - Light teal-gray #91A5A4
    static let textTertiary = Color(hex: "91A5A4")
    
    /// Disabled text - Very light gray #D7E0DE
    static let textDisabled = Color(hex: "D7E0DE")
    
    // MARK: - Background Colors
    
    /// Primary background - Off-white #F8FAF9
    static let backgroundPrimary = Color(hex: "F8FAF9")
    
    /// Secondary background - White
    static let backgroundSecondary = Color.white
    
    /// Card background - White with slight tint
    static let backgroundCard = Color(hex: "FFFFFF")
    
    // MARK: - UI Element Colors
    
    /// Border color - Light mint #E5F2F0
    static let border = Color(hex: "E5F2F0")
    
    /// Divider color
    static let divider = Color(hex: "D7E0DE")
    
    /// Shadow color
    static let shadow = Color.black.opacity(0.08)
    
    // MARK: - Macro Colors
    
    /// Protein color - Vibrant red
    static let macroProtein = Color(hex: "FF6B6B")
    
    /// Carbs color - Warm orange
    static let macroCarbs = Color(hex: "FFA94D")
    
    /// Fat color - Soft purple
    static let macroFat = Color(hex: "9775FA")
    
    /// Calories color - Primary gradient
    static let macroCalories = Color.primaryStart
    
    // MARK: - Status Colors
    
    /// Success color - Green
    static let success = Color(hex: "51CF66")
    
    /// Warning color - Yellow
    static let warning = Color(hex: "FFD43B")
    
    /// Error color - Red
    static let error = Color(hex: "FF6B6B")
    
    /// Info color - Blue
    static let info = Color(hex: "4DABF7")
    
    // MARK: - Chart Colors
    static let chartColors: [Color] = [
        .macroProtein,
        .macroCarbs,
        .macroFat,
        .secondary,
        .accent,
        Color(hex: "845EF7"),
        Color(hex: "FF8787")
    ]
    
    // MARK: - Gradients
    
    /// Primary gradient (teal to aqua)
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [.primaryStart, .primaryEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Secondary gradient (leaf green variations)
    static var secondaryGradient: LinearGradient {
        LinearGradient(
            colors: [.secondary, .secondary.opacity(0.7)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// Card gradient background
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [.white, Color(hex: "F0FFFE")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Helper Initializer
    
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "007B83" or "#007B83")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to hex string
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

// MARK: - Color Scheme Support
extension Color {
    
    /// Adaptive color that changes based on light/dark mode
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
