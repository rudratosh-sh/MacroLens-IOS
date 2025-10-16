//
//  Typography.swift
//  MacroLens
//
//  Typography system and text styles
//

import SwiftUI

// MARK: - Font Extensions
extension Font {
    
    // MARK: - Display Styles (Large headers)
    
    /// Display Large - 34pt Bold
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .default)
    
    /// Display Medium - 28pt Bold
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
    
    /// Display Small - 24pt Semibold
    static let displaySmall = Font.system(size: 24, weight: .semibold, design: .default)
    
    // MARK: - Headline Styles
    
    /// Headline Large - 22pt Semibold
    static let headlineLarge = Font.system(size: 22, weight: .semibold, design: .default)
    
    /// Headline Medium - 20pt Semibold
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .default)
    
    /// Headline Small - 18pt Semibold
    static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .default)
    
    // MARK: - Title Styles
    
    /// Title Large - 20pt Medium
    static let titleLarge = Font.system(size: 20, weight: .medium, design: .default)
    
    /// Title Medium - 18pt Medium
    static let titleMedium = Font.system(size: 18, weight: .medium, design: .default)
    
    /// Title Small - 16pt Medium
    static let titleSmall = Font.system(size: 16, weight: .medium, design: .default)
    
    // MARK: - Body Styles
    
    /// Body Large - 17pt Regular
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    
    /// Body Medium - 15pt Regular
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    
    /// Body Small - 13pt Regular
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)
    
    // MARK: - Label Styles
    
    /// Label Large - 15pt Medium
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)
    
    /// Label Medium - 13pt Medium
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
    
    /// Label Small - 11pt Medium
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
    
    // MARK: - Caption Styles
    
    /// Caption Large - 13pt Regular
    static let captionLarge = Font.system(size: 13, weight: .regular, design: .default)
    
    /// Caption Medium - 12pt Regular
    static let captionMedium = Font.system(size: 12, weight: .regular, design: .default)
    
    /// Caption Small - 11pt Regular
    static let captionSmall = Font.system(size: 11, weight: .regular, design: .default)
    
    // MARK: - Special Styles
    
    /// Number Display - Rounded design for metrics
    static let numberDisplay = Font.system(size: 32, weight: .bold, design: .rounded)
    
    /// Number Large - For macro values
    static let numberLarge = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    /// Number Medium - For secondary metrics
    static let numberMedium = Font.system(size: 18, weight: .medium, design: .rounded)
    
    /// Number Small - For small numeric labels
    static let numberSmall = Font.system(size: 14, weight: .medium, design: .rounded)
    
    /// Button Text - 17pt Semibold
    static let buttonText = Font.system(size: 17, weight: .semibold, design: .default)
    
    /// Button Small - 15pt Semibold
    static let buttonSmall = Font.system(size: 15, weight: .semibold, design: .default)
}

// MARK: - Text Style Modifiers
extension View {
    
    /// Apply display large style
    func displayLarge(color: Color = .textPrimary) -> some View {
        self
            .font(.displayLarge)
            .foregroundColor(color)
    }
    
    /// Apply display medium style
    func displayMedium(color: Color = .textPrimary) -> some View {
        self
            .font(.displayMedium)
            .foregroundColor(color)
    }
    
    /// Apply headline large style
    func headlineLarge(color: Color = .textPrimary) -> some View {
        self
            .font(.headlineLarge)
            .foregroundColor(color)
    }
    
    /// Apply headline medium style
    func headlineMedium(color: Color = .textPrimary) -> some View {
        self
            .font(.headlineMedium)
            .foregroundColor(color)
    }
    
    /// Apply title large style
    func titleLarge(color: Color = .textPrimary) -> some View {
        self
            .font(.titleLarge)
            .foregroundColor(color)
    }
    
    /// Apply body large style
    func bodyLarge(color: Color = .textSecondary) -> some View {
        self
            .font(.bodyLarge)
            .foregroundColor(color)
    }
    
    /// Apply body medium style
    func bodyMedium(color: Color = .textSecondary) -> some View {
        self
            .font(.bodyMedium)
            .foregroundColor(color)
    }
    
    /// Apply label style
    func labelMedium(color: Color = .textSecondary) -> some View {
        self
            .font(.labelMedium)
            .foregroundColor(color)
    }
    
    /// Apply caption style
    func captionMedium(color: Color = .textTertiary) -> some View {
        self
            .font(.captionMedium)
            .foregroundColor(color)
    }
}

// MARK: - Text Line Limit and Truncation
extension View {
    
    /// Apply consistent line limit with truncation
    func limitedLines(_ count: Int = 2) -> some View {
        self
            .lineLimit(count)
            .truncationMode(.tail)
    }
    
    /// Single line with ellipsis
    func singleLine() -> some View {
        self
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

// MARK: - Letter Spacing
extension View {
    
    /// Apply tight letter spacing for numbers
    func numberSpacing() -> some View {
        self.tracking(-0.5)
    }
    
    /// Apply loose letter spacing for headings
    func headingSpacing() -> some View {
        self.tracking(0.5)
    }
}
