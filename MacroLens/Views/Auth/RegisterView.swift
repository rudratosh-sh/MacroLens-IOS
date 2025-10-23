//
//  RegisterView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Auth/RegisterView.swift
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var acceptedTerms = false
    @State private var showTermsAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.spacing24) {
                        
                        // Header
                        VStack(spacing: Constants.UI.spacing12) {
                            Text("Hey there,")
                                .font(.bodyLarge)
                                .foregroundColor(.textSecondary)
                            
                            Text("Create an Account")
                                .font(.displayMedium)
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.top, Constants.UI.spacing32)
                        
                        // Register Form
                        VStack(spacing: Constants.UI.spacing16) {
                            // First Name
                            MLTextField(
                                title: "First Name (Optional)",
                                placeholder: "John",
                                icon: "person",
                                text: $viewModel.registerFirstName
                            )
                            
                            // Last Name
                            MLTextField(
                                title: "Last Name (Optional)",
                                placeholder: "Doe",
                                icon: "person.fill",
                                text: $viewModel.registerLastName
                            )
                            
                            // Email
                            MLTextField.email(
                                text: $viewModel.registerEmail,
                                errorMessage: viewModel.registerEmailError
                            )
                            
                            // Password with Strength Indicator
                            VStack(alignment: .leading, spacing: Constants.UI.spacing8) {
                                MLTextField.password(
                                    text: $viewModel.registerPassword,
                                    errorMessage: viewModel.registerPasswordError,
                                    helperText: "Must be at least 8 characters with uppercase, lowercase, and number"
                                )
                                
                                // Password Strength Bar
                                if !viewModel.registerPassword.isEmpty {
                                    PasswordStrengthBar(
                                        strength: viewModel.getPasswordStrength(viewModel.registerPassword)
                                    )
                                }
                            }
                            
                            // Confirm Password
                            MLTextField.password(
                                title: "Confirm Password",
                                placeholder: "Re-enter your password",
                                text: $viewModel.registerConfirmPassword,
                                errorMessage: viewModel.registerConfirmPasswordError
                            )
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        
                        // Terms Checkbox
                        HStack(spacing: Constants.UI.spacing12) {
                            Button(action: {
                                acceptedTerms.toggle()
                            }) {
                                Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(acceptedTerms ? .primaryStart : .gray2)
                                    .font(.system(size: 24))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("By continuing you accept our")
                                    .font(.captionRegular)
                                    .foregroundColor(.textSecondary)
                                
                                HStack(spacing: 4) {
                                    Button(action: { /* TODO: Show Privacy Policy */ }) {
                                        Text("Privacy Policy")
                                            .font(.captionMedium)
                                            .foregroundColor(.primaryStart)
                                            .underline()
                                    }
                                    
                                    Text("and")
                                        .font(.captionRegular)
                                        .foregroundColor(.textSecondary)
                                    
                                    Button(action: { /* TODO: Show Terms */ }) {
                                        Text("Terms of Use")
                                            .font(.captionMedium)
                                            .foregroundColor(.primaryStart)
                                            .underline()
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        
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
                            .padding(.horizontal, Constants.UI.spacing24)
                        }
                        
                        // Register Button
                        MLButton.primary(
                            "Create Account",
                            icon: "checkmark.circle.fill",
                            size: .large,
                            isLoading: viewModel.isLoading
                        ) {
                            if acceptedTerms {
                                Task {
                                    await viewModel.register()
                                }
                            } else {
                                showTermsAlert = true
                            }
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        .padding(.top, Constants.UI.spacing16)
                        
                        // Divider
                        HStack(spacing: Constants.UI.spacing16) {
                            Rectangle()
                                .fill(Color.gray3)
                                .frame(height: 1)
                            
                            Text("Or")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                            
                            Rectangle()
                                .fill(Color.gray3)
                                .frame(height: 1)
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        
                        // Login Link
                        HStack(spacing: Constants.UI.spacing4) {
                            Text("Already have an account?")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                            
                            Button(action: { dismiss() }) {
                                Text("Login")
                                    .font(.labelLarge)
                                    .foregroundColor(.primaryStart)
                            }
                        }
                        .padding(.bottom, Constants.UI.spacing32)
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
            .alert("Accept Terms", isPresented: $showTermsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please accept the Privacy Policy and Terms of Use to continue")
            }
        }
        .onAppear {
            viewModel.clearErrors()
        }
    }
}

// MARK: - Password Strength Bar Component
struct PasswordStrengthBar: View {
    let strength: PasswordStrength
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.spacing4) {
            HStack(spacing: Constants.UI.spacing4) {
                ForEach(0..<3, id: \.self) { index in
                    Rectangle()
                        .fill(index < strength.bars ? strength.color : Color.gray3)
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            
            Text(strength.text)
                .font(.captionMedium)
                .foregroundColor(strength.color)
        }
    }
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
