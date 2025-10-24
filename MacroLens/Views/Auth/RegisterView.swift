//
//  RegisterView.swift
//  MacroLens
//

import SwiftUI

struct RegisterView: View {
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.spacing20) {
                        
                        // Header
                        VStack(spacing: Constants.UI.spacing8) {
                            Text("Create Account")
                                .font(.displayMedium)
                                .foregroundColor(.textPrimary)
                            
                            Text("Start your macro tracking journey")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, Constants.UI.spacing24)
                        
                        // Register Form
                        VStack(spacing: Constants.UI.spacing12) {
                            
                            // Full Name Field
                            MLTextField(
                                title: "Full Name",
                                placeholder: "John Doe",
                                icon: "person.fill",
                                text: $viewModel.registerFullName,
                                errorMessage: viewModel.registerFullNameError
                            )
                            
                            // Email Field
                            MLTextField.email(
                                text: $viewModel.registerEmail,
                                errorMessage: viewModel.registerEmailError
                            )
                            
                            // Password Field with Strength
                            VStack(alignment: .leading, spacing: Constants.UI.spacing4) {
                                MLTextField.password(
                                    text: $viewModel.registerPassword,
                                    errorMessage: viewModel.registerPasswordError,
                                    helperText: nil
                                )
                                
                                if !viewModel.registerPassword.isEmpty {
                                    VStack(alignment: .leading, spacing: Constants.UI.spacing4) {
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color.border)
                                                    .frame(height: 4)
                                                
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(viewModel.passwordStrength.color)
                                                    .frame(width: geometry.size.width * viewModel.passwordStrength.progress, height: 4)
                                                    .animation(.easeInOut(duration: 0.3), value: viewModel.passwordStrength)
                                            }
                                        }
                                        .frame(height: 4)
                                        
                                        Text(viewModel.passwordStrength.text)
                                            .font(.captionMedium)
                                            .foregroundColor(viewModel.passwordStrength.color)
                                    }
                                    .padding(.horizontal, Constants.UI.spacing4)
                                }
                                
                                Text("Min 8 characters, uppercase, lowercase, number, special char")
                                    .font(.captionSmall)
                                    .foregroundColor(.textTertiary)
                                    .padding(.horizontal, Constants.UI.spacing4)
                                    .padding(.top, Constants.UI.spacing4)
                            }
                            
                            // Confirm Password Field
                            MLTextField.password(
                                title: "Confirm Password",
                                placeholder: "Re-enter your password",
                                text: $viewModel.registerConfirmPassword,
                                errorMessage: viewModel.registerConfirmPasswordError
                            )
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        
                        // Terms & Conditions Checkbox
                        HStack(alignment: .top, spacing: Constants.UI.spacing12) {
                            Button(action: { viewModel.acceptedTerms.toggle() }) {
                                Image(systemName: viewModel.acceptedTerms ? "checkmark.square.fill" : "square")
                                    .font(.iconMedium)
                                    .foregroundColor(viewModel.acceptedTerms ? .primaryStart : .textSecondary)
                            }
                            
                            VStack(alignment: .leading, spacing: Constants.UI.spacing4) {
                                Text("I agree to the ")
                                    .font(.captionMedium)
                                    .foregroundColor(.textSecondary)
                                + Text("Terms of Service")
                                    .font(.captionMedium)
                                    .foregroundColor(.primaryStart)
                                    .underline()
                                + Text(" and ")
                                    .font(.captionMedium)
                                    .foregroundColor(.textSecondary)
                                + Text("Privacy Policy")
                                    .font(.captionMedium)
                                    .foregroundColor(.primaryStart)
                                    .underline()
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        .padding(.top, Constants.UI.spacing4)
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            HStack(spacing: Constants.UI.spacing8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(errorMessage)
                                    .font(.bodyMedium)
                            }
                            .foregroundColor(.error)
                            .padding(.horizontal, Constants.UI.spacing24)
                        }
                        
                        // Create Account Button
                        MLButton.primary(
                            "Create Account",
                            icon: "checkmark.circle.fill",
                            isLoading: viewModel.isLoading
                        ) {
                            Task { await viewModel.register() }
                        }
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        .padding(.horizontal, Constants.UI.spacing24)
                        .padding(.top, Constants.UI.spacing8)
                        
                        // Divider
                        HStack(spacing: Constants.UI.spacing12) {
                            Rectangle()
                                .fill(Color.border)
                                .frame(height: Constants.UI.borderWidthThin)
                            Text("OR")
                                .font(.labelSmall)
                                .foregroundColor(.textTertiary)
                            Rectangle()
                                .fill(Color.border)
                                .frame(height: Constants.UI.borderWidthThin)
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        .padding(.vertical, Constants.UI.spacing8)
                        
                        // Social Sign Up Buttons
                        VStack(spacing: Constants.UI.spacing12) {
                            Button(action: { /* Google Sign Up */ }) {
                                HStack(spacing: Constants.UI.spacing8) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.iconMedium)
                                    Text("Continue with Google")
                                        .font(.buttonSmall)
                                }
                                .foregroundColor(.primaryStart)
                                .frame(maxWidth: .infinity)
                                .frame(height: Constants.UI.buttonHeightMedium)
                                .background(Color.backgroundSecondary)
                                .cornerRadius(Constants.UI.cornerRadiusMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusMedium)
                                        .stroke(Color.border, lineWidth: Constants.UI.borderWidthThin)
                                )
                            }
                            .padding(.horizontal, Constants.UI.spacing24)
                            
                            Button(action: { /* Apple Sign Up */ }) {
                                HStack(spacing: Constants.UI.spacing8) {
                                    Image(systemName: "apple.logo")
                                        .font(.iconMedium)
                                    Text("Continue with Apple")
                                        .font(.buttonSmall)
                                }
                                .foregroundColor(.primaryStart)
                                .frame(maxWidth: .infinity)
                                .frame(height: Constants.UI.buttonHeightMedium)
                                .background(Color.backgroundSecondary)
                                .cornerRadius(Constants.UI.cornerRadiusMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusMedium)
                                        .stroke(Color.border, lineWidth: Constants.UI.borderWidthThin)
                                )
                            }
                            .padding(.horizontal, Constants.UI.spacing24)
                        }
                        
                        // Login Link
                        HStack(spacing: Constants.UI.spacing4) {
                            Text("Already have an account?")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                            
                            Button(action: { dismiss() }) {
                                Text("Sign In")
                                    .font(.labelLarge)
                                    .foregroundColor(.primaryStart)
                            }
                        }
                        .padding(.top, Constants.UI.spacing8)
                        .padding(.bottom, Constants.UI.spacing24)
                    }
                }
                .hideScrollIndicatorsIfAvailable()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.textPrimary)
                            .font(.iconMedium)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        return !viewModel.registerFullName.isEmpty &&
               !viewModel.registerEmail.isEmpty &&
               !viewModel.registerPassword.isEmpty &&
               !viewModel.registerConfirmPassword.isEmpty &&
               viewModel.acceptedTerms &&
               viewModel.registerFullNameError == nil &&
               viewModel.registerEmailError == nil &&
               viewModel.registerPasswordError == nil &&
               viewModel.registerConfirmPasswordError == nil
    }
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
            .previewDevice("iPhone 16")
    }
}
