//
//  MLButton.swift
//  MacroLens
//
//  Custom button component with MacroLens styling
//

import SwiftUI

// MARK: - Button Style Enum
enum MLButtonStyle {
    case primary
    case secondary
    case outline
    case text
    case destructive
}

// MARK: - Button Size Enum
enum MLButtonSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return Constants.UI.buttonHeightSmall
        case .medium: return Constants.UI.buttonHeightMedium
        case .large: return Constants.UI.buttonHeightLarge
        }
    }
    
    var fontSize: Font {
        switch self {
        case .small: return .buttonSmall
        case .medium, .large: return .buttonText
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return Constants.UI.cornerRadiusSmall
        case .medium: return Constants.UI.cornerRadiusMedium
        case .large: return Constants.UI.cornerRadiusLarge
        }
    }
}

// MARK: - MLButton Component
struct MLButton: View {
    
    // MARK: - Properties
    let title: String
    let icon: String?
    let style: MLButtonStyle
    let size: MLButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    // MARK: - State
    @State private var isPressed = false
    
    // MARK: - Initialization
    init(
        _ title: String,
        icon: String? = nil,
        style: MLButtonStyle = .primary,
        size: MLButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            guard !isDisabled && !isLoading else { return }
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            action()
        }) {
            HStack(spacing: Constants.UI.spacing8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(size.fontSize)
                }
                
                Text(title)
                    .font(size.fontSize)
                    .fontWeight(.semibold)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(backgroundView)
            .cornerRadius(size.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .opacity(isDisabled ? 0.5 : 1.0)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    // MARK: - Style Computed Properties
    
    private var textColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .white
        case .outline:
            return .primaryStart
        case .text:
            return .primaryStart
        case .destructive:
            return .white
        }
    }
    
    private var backgroundView: some View {
        Group {
            switch style {
            case .primary:
                Color.primaryGradient
            case .secondary:
                Color.secondary
            case .outline:
                Color.clear
            case .text:
                Color.clear
            case .destructive:
                Color.error
            }
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outline:
            return .primaryStart
        case .text:
            return .clear
        default:
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outline:
            return Constants.UI.borderWidthMedium
        default:
            return 0
        }
    }
}

// MARK: - Convenience Initializers
extension MLButton {
    
    /// Primary button with gradient
    static func primary(
        _ title: String,
        icon: String? = nil,
        size: MLButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> MLButton {
        MLButton(
            title,
            icon: icon,
            style: .primary,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }
    
    /// Secondary button with solid color
    static func secondary(
        _ title: String,
        icon: String? = nil,
        size: MLButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> MLButton {
        MLButton(
            title,
            icon: icon,
            style: .secondary,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }
    
    /// Outline button
    static func outline(
        _ title: String,
        icon: String? = nil,
        size: MLButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> MLButton {
        MLButton(
            title,
            icon: icon,
            style: .outline,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }
    
    /// Text button (no background)
    static func text(
        _ title: String,
        icon: String? = nil,
        size: MLButtonSize = .medium,
        action: @escaping () -> Void
    ) -> MLButton {
        MLButton(
            title,
            icon: icon,
            style: .text,
            size: size,
            action: action
        )
    }
    
    /// Destructive button (red)
    static func destructive(
        _ title: String,
        icon: String? = nil,
        size: MLButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> MLButton {
        MLButton(
            title,
            icon: icon,
            style: .destructive,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }
}

// MARK: - Preview
struct MLButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Constants.UI.spacing16) {
            MLButton.primary("Primary Button", icon: "checkmark.circle.fill") {
                print("Primary tapped")
            }
            
            MLButton.secondary("Secondary Button") {
                print("Secondary tapped")
            }
            
            MLButton.outline("Outline Button", icon: "arrow.right") {
                print("Outline tapped")
            }
            
            MLButton.text("Text Button") {
                print("Text tapped")
            }
            
            MLButton.destructive("Delete", icon: "trash") {
                print("Delete tapped")
            }
            
            MLButton.primary("Loading", isLoading: true) {
                print("Loading")
            }
            
            MLButton.primary("Disabled", isDisabled: true) {
                print("Disabled")
            }
        }
        .padding()
        .background(Color.backgroundPrimary)
    }
}
