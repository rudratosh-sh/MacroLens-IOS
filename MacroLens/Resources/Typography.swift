//
//  Typography.swift
//  MacroLens
//
//  Path: MacroLens/Resources/Typography.swift
//

import SwiftUI

extension Font {
    
    // MARK: - Title / H1 (26px)
    static let h1Bold = Font.custom("Poppins-Bold", size: 26)
    static let h1SemiBold = Font.custom("Poppins-SemiBold", size: 26)
    static let h1Medium = Font.custom("Poppins-Medium", size: 26)
    static let h1Regular = Font.custom("Poppins-Regular", size: 26)
    
    // MARK: - Title / H2 (24px)
    static let h2Bold = Font.custom("Poppins-Bold", size: 24)
    static let h2SemiBold = Font.custom("Poppins-SemiBold", size: 24)
    static let h2Medium = Font.custom("Poppins-Medium", size: 24)
    static let h2Regular = Font.custom("Poppins-Regular", size: 24)
    
    // MARK: - Title / H3 (22px)
    static let h3Bold = Font.custom("Poppins-Bold", size: 22)
    static let h3SemiBold = Font.custom("Poppins-SemiBold", size: 22)
    static let h3Medium = Font.custom("Poppins-Medium", size: 22)
    static let h3Regular = Font.custom("Poppins-Regular", size: 22)
    
    // MARK: - Title / H4 (20px)
    static let h4Bold = Font.custom("Poppins-Bold", size: 20)
    static let h4SemiBold = Font.custom("Poppins-SemiBold", size: 20)
    static let h4Medium = Font.custom("Poppins-Medium", size: 20)
    static let h4Regular = Font.custom("Poppins-Regular", size: 20)
    
    // MARK: - Text / Subtitle (18px)
    static let subtitleBold = Font.custom("Poppins-Bold", size: 18)
    static let subtitleSemiBold = Font.custom("Poppins-SemiBold", size: 18)
    static let subtitleMedium = Font.custom("Poppins-Medium", size: 18)
    static let subtitleRegular = Font.custom("Poppins-Regular", size: 18)
    
    // MARK: - Text / Large Text (16px)
    static let largeTextBold = Font.custom("Poppins-Bold", size: 16)
    static let largeTextSemiBold = Font.custom("Poppins-SemiBold", size: 16)
    static let largeTextMedium = Font.custom("Poppins-Medium", size: 16)
    static let largeTextRegular = Font.custom("Poppins-Regular", size: 16)
    
    // MARK: - Text / Medium Text (14px)
    static let mediumTextBold = Font.custom("Poppins-Bold", size: 14)
    static let mediumTextSemiBold = Font.custom("Poppins-SemiBold", size: 14)
    static let mediumTextMedium = Font.custom("Poppins-Medium", size: 14)
    static let mediumTextRegular = Font.custom("Poppins-Regular", size: 14)
    
    // MARK: - Text / Small Text (12px)
    static let smallTextBold = Font.custom("Poppins-Bold", size: 12)
    static let smallTextSemiBold = Font.custom("Poppins-SemiBold", size: 12)
    static let smallTextMedium = Font.custom("Poppins-Medium", size: 12)
    static let smallTextRegular = Font.custom("Poppins-Regular", size: 12)
    
    // MARK: - Text / Caption (10px)
    static let captionBold = Font.custom("Poppins-Bold", size: 10)
    static let captionSemiBold = Font.custom("Poppins-SemiBold", size: 10)
    static let captionMedium = Font.custom("Poppins-Medium", size: 10)
    static let captionRegular = Font.custom("Poppins-Regular", size: 10)
    
    // MARK: - Links (Medium weight)
    static let linkSmall = Font.custom("Poppins-Medium", size: 10)  // Line height: 15
    static let linkMedium = Font.custom("Poppins-Medium", size: 12) // Line height: 18
    static let linkLarge = Font.custom("Poppins-Medium", size: 14)  // Line height: 21
    
    // MARK: - Legacy Aliases (for backward compatibility)
    static let displayLarge = h1Bold
    static let displayMedium = h2Bold
    static let displaySmall = h3Bold
    static let headlineLarge = h3SemiBold
    static let headlineMedium = h4SemiBold
    static let headlineSmall = subtitleSemiBold
    static let titleLarge = h4Medium
    static let titleMedium = subtitleMedium
    static let titleSmall = largeTextMedium
    static let bodyLarge = largeTextRegular
    static let bodyMedium = mediumTextRegular
    static let bodySmall = smallTextRegular
    static let labelLarge = mediumTextMedium
    static let labelMedium = smallTextMedium
    static let labelSmall = captionMedium
    static let captionLarge = smallTextRegular
    static let captionMediumAlias = captionRegular
    static let captionSmall = captionRegular
    static let buttonText = largeTextSemiBold
    static let buttonSmall = mediumTextSemiBold
    static let buttonMedium = mediumTextSemiBold
}

// MARK: - Text Style Modifiers
extension View {
    
    // H1
    func h1Bold(color: Color = .textPrimary) -> some View {
        self.font(.h1Bold).foregroundColor(color).lineSpacing(39)
    }
    func h1SemiBold(color: Color = .textPrimary) -> some View {
        self.font(.h1SemiBold).foregroundColor(color).lineSpacing(39)
    }
    func h1Medium(color: Color = .textPrimary) -> some View {
        self.font(.h1Medium).foregroundColor(color).lineSpacing(39)
    }
    func h1Regular(color: Color = .textPrimary) -> some View {
        self.font(.h1Regular).foregroundColor(color).lineSpacing(39)
    }
    
    // H2
    func h2Bold(color: Color = .textPrimary) -> some View {
        self.font(.h2Bold).foregroundColor(color).lineSpacing(36)
    }
    func h2SemiBold(color: Color = .textPrimary) -> some View {
        self.font(.h2SemiBold).foregroundColor(color).lineSpacing(36)
    }
    
    // H3
    func h3Bold(color: Color = .textPrimary) -> some View {
        self.font(.h3Bold).foregroundColor(color).lineSpacing(33)
    }
    func h3SemiBold(color: Color = .textPrimary) -> some View {
        self.font(.h3SemiBold).foregroundColor(color).lineSpacing(33)
    }
    
    // H4
    func h4Bold(color: Color = .textPrimary) -> some View {
        self.font(.h4Bold).foregroundColor(color).lineSpacing(30)
    }
    func h4SemiBold(color: Color = .textPrimary) -> some View {
        self.font(.h4SemiBold).foregroundColor(color).lineSpacing(30)
    }
    
    // Subtitle
    func subtitleBold(color: Color = .textPrimary) -> some View {
        self.font(.subtitleBold).foregroundColor(color).lineSpacing(27)
    }
    func subtitleSemiBold(color: Color = .textPrimary) -> some View {
        self.font(.subtitleSemiBold).foregroundColor(color).lineSpacing(27)
    }
    func subtitleRegular(color: Color = .textSecondary) -> some View {
        self.font(.subtitleRegular).foregroundColor(color).lineSpacing(27)
    }
    
    // Large Text
    func largeTextBold(color: Color = .textPrimary) -> some View {
        self.font(.largeTextBold).foregroundColor(color).lineSpacing(24)
    }
    func largeTextRegular(color: Color = .textSecondary) -> some View {
        self.font(.largeTextRegular).foregroundColor(color).lineSpacing(24)
    }
    
    // Medium Text
    func mediumTextBold(color: Color = .textPrimary) -> some View {
        self.font(.mediumTextBold).foregroundColor(color).lineSpacing(21)
    }
    func mediumTextRegular(color: Color = .textSecondary) -> some View {
        self.font(.mediumTextRegular).foregroundColor(color).lineSpacing(5)
    }
    
    // Small Text
    func smallTextBold(color: Color = .textPrimary) -> some View {
        self.font(.smallTextBold).foregroundColor(color).lineSpacing(18)
    }
    func smallTextRegular(color: Color = .textTertiary) -> some View {
        self.font(.smallTextRegular).foregroundColor(color).lineSpacing(18)
    }
    
    // Caption
    func captionRegular(color: Color = .textTertiary) -> some View {
        self.font(.captionRegular).foregroundColor(color).lineSpacing(15)
    }
    
    // Links
    func linkSmall(color: Color = .primaryStart) -> some View {
        self.font(.linkSmall).foregroundColor(color).lineSpacing(15)
    }
    func linkMedium(color: Color = .primaryStart) -> some View {
        self.font(.linkMedium).foregroundColor(color).lineSpacing(18)
    }
    func linkLarge(color: Color = .primaryStart) -> some View {
        self.font(.linkLarge).foregroundColor(color).lineSpacing(21)
    }
}

extension View {
    @ViewBuilder
    func ifAvailableiOS16() -> some View {
        if #available(iOS 16, *) {
            self.scrollIndicators(.hidden)
        } else {
            self
        }
    }
}
