//
//  LoginView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Auth/LoginView.swift
//
//  Description: Login screen with email/password and biometric authentication
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    
    // MARK: - Environment
    @EnvironmentObject var viewModel: AuthViewModel
    
    // MARK: - State
    @State private var showRegisterView = false
    @State private var showForgotPassword = false
    @State private var showPassword = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [Color.backgroundPrimary, Color.backgroundSecondary],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.spacing24) {
                        
                        Spacer()
                            .frame(height: Constants.UI.spacing32)
                        
                        // Logo & Welcome
                        VStack(spacing: Constants.UI.spacing12) {
                            Image("macroLensLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                            
                            Text("Welcome Back")
                                .font(.displayMedium)
                                .foregroundColor(.textPrimary)
                            
                            Text("Track your macros with AI")
                                .font(.bodyLarge)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.bottom, Constants.UI.spacing16)
                        
                        // Login Form
                        VStack(spacing: Constants.UI.spacing16) {
                            
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
                                Button(action: {
                                    showForgotPassword = true
                                }) {
                                    Text("Forgot Password?")
                                        .font(.bodyMedium)
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
                        
                        // Sign In Button
                        MLButton.primary(
                            "Sign In",
                            icon: "arrow.right.circle.fill",
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                await viewModel.login()
                                // ✅ Show biometric prompt after successful login if available and not yet enabled
                                if viewModel.isAuthenticated &&
                                    viewModel.biometricType() != .none &&
                                    !viewModel.canUseBiometric {
                                    viewModel.showBiometricPrompt = true
                                }
                            }
                        }
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        .padding(.horizontal, Constants.UI.spacing24)
                        .padding(.top, Constants.UI.spacing8)
                        
                        // Biometric Login Button
                        if viewModel.canUseBiometric {
                            Button(action: {
                                Task {
                                    await viewModel.loginWithBiometrics()
                                }
                            }) {
                                HStack(spacing: Constants.UI.spacing8) {
                                    Image(systemName: biometricIcon)
                                        .font(.iconMedium)
                                    Text("Sign in with \(viewModel.biometricDisplayName())")
                                        .font(.buttonMedium)
                                }
                                .foregroundColor(.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: Constants.UI.buttonHeightMedium)
                                .background(Color.backgroundSecondary)
                                .cornerRadius(Constants.UI.cornerRadiusMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusMedium)
                                        .stroke(Color.border, lineWidth: Constants.UI.borderWidthThin)
                                )
                            }
                            .disabled(viewModel.isLoading)
                            .padding(.horizontal, Constants.UI.spacing24)
                        }
                        
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
                        
                        // Social Login Buttons
                        VStack(spacing: Constants.UI.spacing12) {
                            
                            // Google Sign In
                            Button(action: {
                                // TODO: Implement Google Sign In
                            }) {
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
                            
                            // Apple Sign In
                            Button(action: {
                                // TODO: Implement Apple Sign In
                            }) {
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
                        .padding(.top, Constants.UI.spacing16)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRegisterView) {
                if #available(iOS 16.0, *) {
                    RegisterView()
                        .environmentObject(viewModel)
                } else {
                    // Fallback on earlier versions
                }
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
            // ✅ UPDATED: Biometric enrollment alert
            .alert("Enable \(viewModel.biometricDisplayName())?", isPresented: $viewModel.showBiometricPrompt) {
                Button("Enable") {
                    Task {
                        await viewModel.enableBiometric(
                            email: viewModel.loginEmail,
                            password: viewModel.loginPassword
                        )
                    }
                }
                Button("Not Now", role: .cancel) {
                    viewModel.skipBiometricEnrollment()
                }
            } message: {
                Text("Use \(viewModel.biometricDisplayName()) to quickly sign in next time")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Check if form is valid for submission
    private var isFormValid: Bool {
        return !viewModel.loginEmail.isEmpty &&
               !viewModel.loginPassword.isEmpty &&
               viewModel.loginEmailError == nil &&
               viewModel.loginPasswordError == nil
    }
    
    /// Get biometric icon name
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
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
