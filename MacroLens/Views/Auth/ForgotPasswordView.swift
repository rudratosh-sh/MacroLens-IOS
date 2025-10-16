//
//  ForgotPasswordView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Auth/ForgotPasswordView.swift
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var emailError: String?
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    private let authService = AuthService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.spacing32) {
                        
                        // Icon
                        Image(systemName: "lock.rotation")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(Color.primaryGradient)
                            .padding(.top, 60)
                        
                        // Header
                        VStack(spacing: Constants.UI.spacing12) {
                            Text("Forgot Password?")
                                .font(.displayMedium)
                                .foregroundColor(.textPrimary)
                            
                            Text("Enter your email and we'll send you a reset link")
                                .font(.bodyLarge)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        
                        // Email Input
                        VStack(spacing: Constants.UI.spacing16) {
                            MLTextField.email(
                                text: $email,
                                errorMessage: emailError
                            )
                            
                            // Error Message
                            if let errorMessage = errorMessage {
                                HStack(spacing: Constants.UI.spacing8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text(errorMessage)
                                        .font(.bodyMedium)
                                }
                                .foregroundColor(.error)
                            }
                            
                            // Success Message
                            if showSuccess {
                                HStack(spacing: Constants.UI.spacing8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Reset link sent! Check your email.")
                                        .font(.bodyMedium)
                                }
                                .foregroundColor(.success)
                            }
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        
                        // Reset Button
                        MLButton.primary(
                            "Send Reset Link",
                            icon: "paperplane.fill",
                            isLoading: isLoading
                        ) {
                            Task {
                                await sendResetLink()
                            }
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func sendResetLink() async {
        // Validate email
        let validation = ValidationHelper.validateEmail(email)
        guard validation.isValid else {
            emailError = validation.errorMessage
            return
        }
        
        emailError = nil
        errorMessage = nil
        isLoading = true
        
        do {
            try await authService.requestPasswordReset(email: email.trimmingCharacters(in: .whitespaces))
            showSuccess = true
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dismiss()
            }
        } catch {
            errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
        }
        
        isLoading = false
    }
}

// MARK: - Preview
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
