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
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Text("Hey there,")
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                    
                    Text("Create an Account")
                        .font(.displayMedium)
                        .foregroundColor(.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 60)
                
                // Form
                VStack(spacing: 16) {
                    // First Name
                    MLTextField(
                        title: "",
                        placeholder: "First Name",
                        icon: "person",
                        type: .text,
                        text: $viewModel.registerFirstName
                    )
                    
                    // Last Name
                    MLTextField(
                        title: "",
                        placeholder: "Last Name",
                        icon: "person.fill",
                        type: .text,
                        text: $viewModel.registerLastName
                    )
                    
                    // Email
                    MLTextField(
                        title: "",
                        placeholder: "Email",
                        icon: "envelope",
                        type: .email,
                        text: $viewModel.registerEmail,
                        errorMessage: viewModel.registerEmailError
                    )
                    
                    // Password
                    MLTextField(
                        title: "",
                        placeholder: "Password",
                        icon: "lock",
                        type: .password,
                        text: $viewModel.registerPassword,
                        errorMessage: viewModel.registerPasswordError
                    )
                    
                    // Password Strength Indicator (if password not empty)
                    if !viewModel.registerPassword.isEmpty {
                        PasswordStrengthIndicator(
                            strength: viewModel.getPasswordStrength(viewModel.registerPassword)
                        )
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, 30)
                
                // Terms Checkbox
                HStack(spacing: 12) {
                    Button(action: {
                        acceptedTerms.toggle()
                    }) {
                        Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                            .foregroundColor(acceptedTerms ? .primaryStart : .gray2)
                            .font(.system(size: 20))
                    }
                    
                    HStack(spacing: 4) {
                        Text("By continuing you accept our")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        
                        Button(action: {
                            // TODO: Show Privacy Policy
                        }) {
                            Text("Privacy Policy")
                                .font(.captionMedium)
                                .foregroundColor(.textSecondary)
                                .underline()
                        }
                        
                        Text("and")
                            .font(.captionRegular)
                            .foregroundColor(.textSecondary)
                        
                        Button(action: {
                            // TODO: Show Terms of Use
                        }) {
                            Text("Term of Use")
                                .font(.captionMedium)
                                .foregroundColor(.textSecondary)
                                .underline()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(errorMessage)
                            .font(.captionMedium)
                    }
                    .foregroundColor(.error)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.error.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 30)
                }
                
                // Register Button
                MLButton.primary(
                    "Register",
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
                .padding(.horizontal, 30)
                .padding(.top, 80)
                
                // Divider
                HStack(spacing: 16) {
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
                .padding(.horizontal, 30)
                .padding(.top, 16)
                
                // Social Login Buttons
                HStack(spacing: 16) {
                    // Google Button
                    Button(action: {
                        // TODO: Implement Google Sign In
                    }) {
                        Image(systemName: "g.circle.fill") // Replace with Google icon
                            .font(.system(size: 20))
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                    }
                    
                    // Facebook Button
                    Button(action: {
                        // TODO: Implement Facebook Sign In
                    }) {
                        Image(systemName: "f.circle.fill") // Replace with Facebook icon
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                    }
                }
                .padding(.top, 16)
                
                // Login Link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Login")
                            .font(.bodyMedium)
                            .foregroundColor(.primaryStart)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.textPrimary)
                }
            }
        }
        .alert("Accept Terms", isPresented: $showTermsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please accept the Privacy Policy and Terms of Use to continue")
        }
        .onAppear {
            viewModel.clearErrors()
        }
    }
}

// MARK: - Password Strength Indicator
struct PasswordStrengthIndicator: View {
    let strength: PasswordStrength
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
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
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    RegisterView()
                        .environmentObject(AuthViewModel())
                }
            } else {
                NavigationView {
                    RegisterView()
                        .environmentObject(AuthViewModel())
                }
            }
        }
    }
}
