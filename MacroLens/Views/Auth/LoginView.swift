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
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [Color.primaryStart, Color.primaryEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 0) {
                    // Top Section - Logo & Title
                    VStack(spacing: Constants.UI.spacing24) {
                        Spacer()
                            .frame(height: Constants.UI.spacing64)
                        
                        // Logo
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "camera.macro")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: Constants.UI.spacing8) {
                            Text("MacroLens")
                                .font(.displayLarge)
                                .foregroundColor(.white)
                            
                            Text("See your macros, powered by AI")
                                .font(.bodyLarge)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Spacer()
                            .frame(height: Constants.UI.spacing32)
                    }
                    
                    // Bottom Section - Login Form
                    VStack(spacing: Constants.UI.spacing20) {
                        VStack(spacing: Constants.UI.spacing20) {
                            // Email Field
                            MLTextField.email(
                                text: $viewModel.loginEmail,
                                errorMessage: viewModel.loginEmailError
                            )
                            
                            // Password Field
                            MLTextField.password(
                                text: $viewModel.loginPassword,
                                errorMessage: viewModel.loginPasswordError
                            )
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                Button(action: { showForgotPassword = true }) {
                                    Text("Forgot Password?")
                                        .font(.bodyMedium)
                                        .foregroundColor(.primaryStart)
                                }
                            }
                            .padding(.top, -Constants.UI.spacing8)
                            
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
                            
                            // Login Button
                            MLButton.primary(
                                "Log In",
                                icon: "arrow.right.circle.fill",
                                size: .large,
                                isLoading: viewModel.isLoading
                            ) {
                                Task {
                                    await viewModel.login()
                                }
                            }
                            .padding(.top, Constants.UI.spacing8)
                            
                            // Biometric Login
                            if biometricTypeAvailable != .none {
                                MLButton.outline(
                                    "Login with \(biometricName)",
                                    icon: biometricIcon,
                                    size: .large
                                ) {
                                    Task {
                                        _ = await viewModel.loginWithBiometrics()
                                    }
                                }
                            }
                            
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
                            .padding(.vertical, Constants.UI.spacing8)
                            
                            // Register Link
                            HStack(spacing: Constants.UI.spacing4) {
                                Text("Don't have an account?")
                                    .font(.bodyMedium)
                                    .foregroundColor(.textSecondary)
                                
                                Button(action: { showRegisterView = true }) {
                                    Text("Sign Up")
                                        .font(.labelLarge)
                                        .foregroundColor(.primaryStart)
                                }
                            }
                        }
                        .padding(.horizontal, Constants.UI.spacing24)
                        .padding(.top, Constants.UI.spacing32)
                        .padding(.bottom, Constants.UI.spacing40)
                    }
                    .background(
                        Color.backgroundPrimary
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            .ignoresSafeArea()
                    )
                }
            }
        }
        .sheet(isPresented: $showRegisterView) {
            RegisterView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(viewModel)
        }
        .onAppear {
            viewModel.clearErrors()
        }
    }
    
    // MARK: - Biometric Helpers
    
    private var biometricTypeAvailable: LABiometryType {
        viewModel.biometricType()
    }
    
    private var biometricIcon: String {
        switch biometricTypeAvailable {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.fill"
        }
    }
    
    private var biometricName: String {
        switch biometricTypeAvailable {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Biometrics"
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
