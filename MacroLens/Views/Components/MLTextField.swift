//
//  MLTextField.swift
//  MacroLens
//
//  Custom text field component with MacroLens styling
//

import SwiftUI

// MARK: - Text Field Type
enum MLTextFieldType {
    case text
    case email
    case password
    case number
    case decimal
    case phone
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .text, .password:
            return .default
        case .email:
            return .emailAddress
        case .number:
            return .numberPad
        case .decimal:
            return .decimalPad
        case .phone:
            return .phonePad
        }
    }
    
    var autocapitalization: TextInputAutocapitalization {
        switch self {
        case .email, .password:
            return .never
        default:
            return .sentences
        }
    }
    
    var contentType: UITextContentType? {
        switch self {
        case .email:
            return .emailAddress
        case .password:
            return .password
        case .phone:
            return .telephoneNumber
        default:
            return nil
        }
    }
}

// MARK: - MLTextField Component
struct MLTextField: View {
    
    // MARK: - Properties
    let title: String
    let placeholder: String
    let icon: String?
    let type: MLTextFieldType
    let errorMessage: String?
    let helperText: String?
    
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible = false
    
    // MARK: - Initialization
    init(
        title: String = "",
        placeholder: String,
        icon: String? = nil,
        type: MLTextFieldType = .text,
        text: Binding<String>,
        errorMessage: String? = nil,
        helperText: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self.type = type
        self._text = text
        self.errorMessage = errorMessage
        self.helperText = helperText
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.spacing8) {
            // Title Label
            if !title.isEmpty {
                Text(title)
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)
            }
            
            // Text Field Container
            HStack(spacing: Constants.UI.spacing12) {
                // Leading Icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Constants.UI.iconSizeMedium))
                        .foregroundColor(iconColor)
                }
                
                // Text Field
                Group {
                    if type == .password && !isPasswordVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(type.keyboardType)
                            .textInputAutocapitalization(type.autocapitalization)
                            .textContentType(type.contentType)
                            .autocorrectionDisabled(type == .email || type == .password)
                    }
                }
                .font(.bodyLarge)
                .foregroundColor(.textPrimary)
                .focused($isFocused)
                
                // Password Visibility Toggle
                if type == .password {
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: Constants.UI.iconSizeMedium))
                            .foregroundColor(.textTertiary)
                    }
                }
                
                // Clear Button
                if !text.isEmpty && isFocused && type != .password {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: Constants.UI.iconSizeMedium))
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(.horizontal, Constants.UI.spacing16)
            .padding(.vertical, Constants.UI.spacing12)
            .background(Color.backgroundSecondary)
            .cornerRadius(Constants.UI.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusMedium)
                    .stroke(borderColor, lineWidth: Constants.UI.borderWidthMedium)
            )
            
            // Helper Text or Error Message
            if let errorMessage = errorMessage {
                HStack(spacing: Constants.UI.spacing4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.captionMedium)
                    Text(errorMessage)
                        .font(.captionMedium)
                }
                .foregroundColor(.error)
            } else if let helperText = helperText {
                Text(helperText)
                    .font(.captionMedium)
                    .foregroundColor(.textTertiary)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var borderColor: Color {
        if errorMessage != nil {
            return .error
        } else if isFocused {
            return .primaryStart
        } else {
            return .border
        }
    }
    
    private var iconColor: Color {
        if errorMessage != nil {
            return .error
        } else if isFocused {
            return .primaryStart
        } else {
            return .textTertiary
        }
    }
}

// MARK: - Convenience Initializers
extension MLTextField {
    
    /// Email text field
    static func email(
        title: String = "Email",
        placeholder: String = "Enter your email",
        text: Binding<String>,
        errorMessage: String? = nil
    ) -> MLTextField {
        MLTextField(
            title: title,
            placeholder: placeholder,
            icon: "envelope",
            type: .email,
            text: text,
            errorMessage: errorMessage
        )
    }
    
    /// Password text field
    static func password(
        title: String = "Password",
        placeholder: String = "Enter your password",
        text: Binding<String>,
        errorMessage: String? = nil,
        helperText: String? = nil
    ) -> MLTextField {
        MLTextField(
            title: title,
            placeholder: placeholder,
            icon: "lock",
            type: .password,
            text: text,
            errorMessage: errorMessage,
            helperText: helperText
        )
    }
    
    /// Number text field
    static func number(
        title: String,
        placeholder: String,
        icon: String? = nil,
        text: Binding<String>,
        errorMessage: String? = nil
    ) -> MLTextField {
        MLTextField(
            title: title,
            placeholder: placeholder,
            icon: icon,
            type: .number,
            text: text,
            errorMessage: errorMessage
        )
    }
    
    /// Decimal text field (for weights, measurements)
    static func decimal(
        title: String,
        placeholder: String,
        icon: String? = nil,
        text: Binding<String>,
        errorMessage: String? = nil
    ) -> MLTextField {
        MLTextField(
            title: title,
            placeholder: placeholder,
            icon: icon,
            type: .decimal,
            text: text,
            errorMessage: errorMessage
        )
    }
}

// MARK: - Preview
struct MLTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Constants.UI.spacing20) {
            MLTextField.email(
                text: .constant(""),
                errorMessage: nil
            )
            
            MLTextField.password(
                text: .constant(""),
                helperText: "Must be at least 8 characters"
            )
            
            MLTextField(
                title: "Full Name",
                placeholder: "John Doe",
                icon: "person",
                text: .constant("")
            )
            
            MLTextField.decimal(
                title: "Weight (kg)",
                placeholder: "70.5",
                icon: "scalemass",
                text: .constant("")
            )
            
            MLTextField.email(
                text: .constant("invalid-email"),
                errorMessage: "Please enter a valid email address"
            )
        }
        .padding()
        .background(Color.backgroundPrimary)
    }
}
