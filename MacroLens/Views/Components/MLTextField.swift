//
//  MLTextField.swift
//  MacroLens
//
//  Path: MacroLens/Views/Components/MLTextField.swift
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
        VStack(alignment: .leading, spacing: 8) {
            // Title (if provided)
            if !title.isEmpty {
                Text(title)
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)
            }
            
            // Text Field Container
            HStack(spacing: 12) {
                // Leading Icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.gray2)
                        .frame(width: 20, height: 20)
                }
                
                // Text Input
                Group {
                    if type == .password && !isPasswordVisible {
                        SecureField(placeholder, text: $text)
                            .textContentType(type.contentType)
                            .autocorrectionDisabled()
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(type.keyboardType)
                            .textInputAutocapitalization(type.autocapitalization)
                            .textContentType(type.contentType)
                            .autocorrectionDisabled(type == .email)
                    }
                }
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)
                .focused($isFocused)
                
                // Trailing Actions
                if type == .password {
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.gray2)
                    }
                } else if !text.isEmpty && isFocused {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.gray2)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.95, green: 0.96, blue: 0.97)) // Light gray background #F7F8F8
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: 1)
            )
            
            // Helper Text or Error Message
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
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
            return .clear // No border when focused
        } else {
            return .clear // No border in normal state
        }
    }
}

// MARK: - Convenience Initializers
extension MLTextField {
    
    /// Email text field
    static func email(
        title: String = "",
        placeholder: String = "Email",
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
        title: String = "",
        placeholder: String = "Password",
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
        VStack(spacing: 20) {
            MLTextField.email(
                text: .constant(""),
                errorMessage: nil
            )
            
            MLTextField.password(
                text: .constant(""),
                helperText: "Must be at least 8 characters"
            )
            
            MLTextField(
                placeholder: "First Name",
                icon: "person",
                text: .constant("")
            )
            
            MLTextField.email(
                text: .constant("invalid"),
                errorMessage: "Please enter a valid email address"
            )
        }
        .padding()
        .background(Color.white)
    }
}
