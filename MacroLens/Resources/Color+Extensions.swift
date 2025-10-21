//
//  Color+Extensions.swift
//  MacroLens
//
//  Path: MacroLens/Resources/Color+Extensions.swift
//

import SwiftUI

extension Color {
    
    // MARK: - Brand Colors (Primary)
    static let primaryStart = Color(hex: "007B83")
    static let primaryEnd = Color(hex: "00BFA6")
    
    // MARK: - Secondary Colors
    static let secondaryStart = Color(hex: "6CCB7E")
    static let secondaryEnd = Color(hex: "A3E4D7")
    
    // MARK: - Black Colors (Text)
    static let blackPrimary = Color(hex: "1D1617")
    static let blackSecondary = Color.white
    
    // MARK: - Gray Colors
    static let gray1 = Color(hex: "587072")
    static let gray2 = Color(hex: "91A5A4")
    static let gray3 = Color(hex: "D7E0DE")
    
    // MARK: - Border Color
    static let borderColor = Color(hex: "E5F2F0")
    
    // MARK: - Text Colors (Aliases)
    static let textPrimary = Color.blackPrimary
    static let textSecondary = Color.gray1
    static let textTertiary = Color.gray2
    static let textDisabled = Color.gray3
    
    // MARK: - Background Colors
    static let backgroundPrimary = Color(hex: "F8FAF9")
    static let backgroundSecondary = Color.white
    static let backgroundCard = Color.white
    
    // MARK: - UI Element Colors
    static let border = Color.borderColor
    static let divider = Color.gray3
    static let shadow = Color.black.opacity(0.08)
    
    // MARK: - Macro Colors
    static let macroProtein = Color(hex: "FF6B6B")
    static let macroCarbs = Color(hex: "FFA94D")
    static let macroFat = Color(hex: "9775FA")
    static let macroCalories = Color.primaryStart
    
    // MARK: - Status Colors
    static let success = Color(hex: "51CF66")
    static let warning = Color(hex: "FFD43B")
    static let error = Color(hex: "FF6B6B")
    static let info = Color(hex: "4DABF7")
    
    // MARK: - Chart Colors
    static let chartColors: [Color] = [
        .macroProtein,
        .macroCarbs,
        .macroFat,
        .secondaryStart,
        .secondaryEnd,
        Color(hex: "845EF7"),
        Color(hex: "FF8787")
    ]
    
    // MARK: - Gradients (Fitnest Style)
    
    /// Primary Linear Gradient
    static var primaryLinear: LinearGradient {
        LinearGradient(
            colors: [Color.primaryStart, Color.primaryEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// Calories Linear Gradient
    static var caloriesLinear: LinearGradient {
        LinearGradient(
            colors: [Color.primaryEnd, Color.secondaryStart],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// Progress Bar Linear Gradient
    static var progressBarLinear: LinearGradient {
        LinearGradient(
            colors: [Color.primaryStart, Color.secondaryStart],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// Water Intake Linear Gradient
    static var waterIntakeLinear: LinearGradient {
        LinearGradient(
            colors: [Color.primaryEnd, Color.secondaryEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// Logo Linear Gradient
    static var logoLinear: LinearGradient {
        LinearGradient(
            colors: [Color.primaryStart, Color.secondaryEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Legacy Gradients (Aliases)
    static var primaryGradient: LinearGradient { primaryLinear }
    static var secondaryGradient: LinearGradient {
        LinearGradient(
            colors: [.secondaryStart, .secondaryEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [.white, Color(hex: "F0FFFE")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Helper Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b, a: UInt64
        switch hex.count {
        case 6:
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
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

extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
