
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
            ZStack {
                // Background
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.spacing32) {
                        
                        // Logo and Title
                        VStack(spacing: Constants.UI.spacing16) {
                            Image(systemName: "camera.macro")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(Color.primaryGradient)
                            
                            Text("MacroLens")
                                .font(.displayLarge)
                                .foregroundColor(.textPrimary)
                            
                            Text("See your macros, powered by AI")
                                .font(.bodyLarge)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, 60)
                        
                        // Login Form
                        VStack(spacing: Constants.UI.spacing20) {
                            MLTextField.email(
                                text: $viewModel.loginEmail,
                                errorMessage: viewModel.loginEmailError
                            )
                            .textInputAutocapitalization(.never)
                            
                            MLTextField.password(
                                text: $viewModel.loginPassword,
                                errorMessage: viewModel.loginPasswordError
                            )
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                Button(action: {
                                    showForgotPassword = true
                                }) {
                                    Text("Forgot Password?")
                                        .font(.labelMedium)
                                        .foregroundColor(.primaryStart)
                                }
                            }
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
                        
                        // Login Button
                        VStack(spacing: Constants.UI.spacing12) {
                            MLButton.primary(
                                "Log In",
                                icon: "arrow.right.circle.fill",
                                isLoading: viewModel.isLoading
                            ) {
                                Task {
                                    await viewModel.login()
                                }
                            }
                            .padding(.horizontal, Constants.UI.spacing24)
                            
                            // Biometric Login
                            if viewModel.biometricType() != .none {
                                Button(action: {
                                    Task {
                                        _ = await viewModel.loginWithBiometrics()
                                    }
                                }) {
                                    HStack(spacing: Constants.UI.spacing8) {
                                        Image(systemName: biometricIcon)
                                            .font(.system(size: Constants.UI.iconSizeMedium))
                                        Text("Login with \(biometricName)")
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
                        }
                        
                        // Register Link
                        HStack(spacing: Constants.UI.spacing4) {
                            Text("Don't have an account?")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                            
                            Button(action: {
                                showRegisterView = true
                            }) {
                                Text("Sign Up")
                                    .font(.labelLarge)
                                    .foregroundColor(.primaryStart)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRegisterView) {
                RegisterView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
    
    // MARK: - Biometric Helpers
    
    private var biometricIcon: String {
        switch viewModel.biometricType() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock.fill"
        }
    }
    
    private var biometricName: String {
        switch viewModel.biometricType() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometrics"
        }
    }
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
