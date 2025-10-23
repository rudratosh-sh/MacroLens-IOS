//
//  ForgotPasswordView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Auth/ForgotPasswordView.swift
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.spacing32) {
                        
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.primaryStart.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "lock.rotation")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.primaryStart)
                        }
                        .padding(.top, Constants.UI.spacing64)
                        
                        // Header
                        VStack(spacing: Constants.UI.spacing12) {
                            Text("Forgot Password?")
                                .font(.displayMedium)
                                .foregroundColor(.textPrimary)
                            
                            Text("Enter your email address and we'll send you a link to reset your password")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Constants.UI.spacing32)
                        }
                        
                        // Form
                        VStack(spacing: Constants.UI.spacing20) {
                            // Email Field
                            MLTextField.email(
                                text: $viewModel.forgotPasswordEmail,
                                errorMessage: viewModel.forgotPasswordEmailError
                            )
                            
                            // Error Message
                            if let errorMessage = viewModel.errorMessage {
                                HStack(spacing: Constants.UI.spacing8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text(errorMessage)
                                        .font(.bodySmall)
                                }
                                .foregroundColor(.error)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.error.opacity(0.1))
                                .cornerRadius(Constants.UI.cornerRadiusMedium)
                            }
                            
                            // Success Message
                            if let successMessage = viewModel.successMessage {
                                HStack(spacing: Constants.UI.spacing8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(successMessage)
                                        .font(.bodySmall)
                                }
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(Constants.UI.cornerRadiusMedium)
                            }
                            
                            // Send Link Button
                            MLButton.primary(
                                "Send Reset Link",
                                icon: "paperplane.fill",
                                size: .large,
                                isLoading: viewModel.isLoading
                            ) {
                                Task {
                                    await viewModel.resetPassword()
                                    if viewModel.successMessage != nil {
                                        showSuccessMessage = true
                                        // Auto dismiss after 2 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            dismiss()
                                        }
                                    }
                                }
                            }
                            
                            // Back to Login
                            Button(action: { dismiss() }) {
                                HStack(spacing: Constants.UI.spacing8) {
                                    Image(systemName: "arrow.left")
                                    Text("Back to Login")
                                }
                                .font(.bodyMedium)
                                .foregroundColor(.primaryStart)
                            }
                            .padding(.top, Constants.UI.spacing8)
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.clearErrors()
        }
    }
}

// MARK: - Preview
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
            .environmentObject(AuthViewModel())
    }
}
