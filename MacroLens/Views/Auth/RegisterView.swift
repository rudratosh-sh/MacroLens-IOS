//
//  RegisterView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Auth/RegisterView.swift
//

import SwiftUI

struct RegisterView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.spacing24) {
                        
                        // Header
                        VStack(spacing: Constants.UI.spacing12) {
                            Text("Create Account")
                                .font(.displayMedium)
                                .foregroundColor(.textPrimary)
                            
                            Text("Join MacroLens and start tracking")
                                .font(.bodyLarge)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, Constants.UI.spacing32)
                        
                        // Register Form
                        VStack(spacing: Constants.UI.spacing16) {
                            MLTextField(
                                title: "First Name (Optional)",
                                placeholder: "John",
                                icon: "person",
                                text: $viewModel.registerFirstName
                            )
                            
                            MLTextField(
                                title: "Last Name (Optional)",
                                placeholder: "Doe",
                                icon: "person",
                                text: $viewModel.registerLastName
                            )
                            
                            MLTextField.email(
                                text: $viewModel.registerEmail,
                                errorMessage: viewModel.registerEmailError
                            )
                            
                            MLTextField.password(
                                text: $viewModel.registerPassword,
                                errorMessage: viewModel.registerPasswordError,
                                helperText: "At least 8 characters with uppercase, lowercase, and number"
                            )
                            
                            MLTextField.password(
                                title: "Confirm Password",
                                placeholder: "Re-enter your password",
                                text: $viewModel.registerConfirmPassword,
                                errorMessage: viewModel.registerConfirmPasswordError
                            )
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        
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
                        
                        // Register Button
                        MLButton.primary(
                            "Create Account",
                            icon: "checkmark.circle.fill",
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                await viewModel.register()
                            }
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        .padding(.top, Constants.UI.spacing8)
                        
                        // Terms
                        Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                            .font(.captionMedium)
                            .foregroundColor(.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Constants.UI.spacing32)
                        
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
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
