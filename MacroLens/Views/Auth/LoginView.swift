//
//  LoginView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Auth/LoginView.swift
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showRegisterView = false
    @State private var showForgotPassword = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Hey there,")
                            .font(.bodyLarge)
                            .foregroundColor(.textSecondary)
                        
                        Text("Welcome Back")
                            .font(.displayMedium)
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 60)
                    
                    // Form
                    VStack(spacing: 16) {
                        // Email Field
                        MLTextField(
                            title: "",
                            placeholder: "Email",
                            icon: "envelope",
                            type: .email,
                            text: $viewModel.loginEmail,
                            errorMessage: viewModel.loginEmailError
                        )
                        
                        // Password Field
                        MLTextField(
                            title: "",
                            placeholder: "Password",
                            icon: "lock",
                            type: .password,
                            text: $viewModel.loginPassword,
                            errorMessage: viewModel.loginPasswordError
                        )
                        
                        // Forgot Password Link
                        Button(action: {
                            showForgotPassword = true
                        }) {
                            Text("Forgot your password?")
                                .font(.captionMedium)
                                .foregroundColor(.textSecondary)
                                .underline()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
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
                    
                    // Login Button
                    MLButton.primary(
                        "Login",
                        size: .large,
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            await viewModel.login()
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 100)
                    
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
                            HStack(spacing: 8) {
                                Image(systemName: "g.circle.fill") // Replace with Google icon
                                    .font(.system(size: 20))
                            }
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
                            HStack(spacing: 8) {
                                Image(systemName: "f.circle.fill") // Replace with Facebook icon
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
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
                    
                    // Register Link
                    HStack(spacing: 4) {
                        Text("Don't have an account yet?")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                        
                        Button(action: {
                            showRegisterView = true
                        }) {
                            Text("Register")
                                .font(.bodyMedium)
                                .foregroundColor(.primaryStart)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
                .background(
                    Group {
                        // Hidden navigation triggers for iOS < 16
                        NavigationLink(
                            destination: RegisterView().environmentObject(viewModel),
                            isActive: $showRegisterView
                        ) { EmptyView() }
                        .hidden()
                        
                        NavigationLink(
                            destination: ForgotPasswordView().environmentObject(viewModel),
                            isActive: $showForgotPassword
                        ) { EmptyView() }
                        .hidden()
                    }
                )
            }
            .background(Color.white)
        }
        .onAppear {
            viewModel.clearErrors()
        }
    }
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
