//
//  LoginView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Auth/LoginView.swift
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    
    @StateObject private var viewModel = AuthViewModel()
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
            VStack(spacing: 0) {
                // Top Section - Logo & Title
                VStack(spacing: 24) {
                    Spacer()
                    
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
                    
                    VStack(spacing: 8) {
                        Text("MacroLens")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("See your macros, powered by AI")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                }
                .frame(height: UIScreen.main.bounds.height * 0.4)
                
                // Bottom Section - Login Form
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.textTertiary)
                                    .frame(width: 20)
                                
                                TextField("Enter your email", text: $viewModel.loginEmail)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            }
                            .padding()
                            .background(Color.backgroundSecondary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.loginEmailError != nil ? Color.error : Color.border, lineWidth: 1)
                            )
                            
                            if let error = viewModel.loginEmailError {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.error)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textSecondary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.textTertiary)
                                    .frame(width: 20)
                                
                                SecureField("Enter your password", text: $viewModel.loginPassword)
                            }
                            .padding()
                            .background(Color.backgroundSecondary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.loginPasswordError != nil ? Color.error : Color.border, lineWidth: 1)
                            )
                            
                            if let error = viewModel.loginPasswordError {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.error)
                            }
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button(action: { showForgotPassword = true }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primaryStart)
                            }
                        }
                        .padding(.top, -8)
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(errorMessage)
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.error)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.error.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Login Button
                        Button(action: {
                            Task { await viewModel.login() }
                        }) {
                            HStack(spacing: 12) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(viewModel.isLoading ? "Logging in..." : "Log In")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color.primaryStart, Color.primaryEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.primaryStart.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.top, 8)
                        
                        // Biometric Login
                        if viewModel.biometricType() != .none {
                            Button(action: {
                                Task { _ = await viewModel.loginWithBiometrics() }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: biometricIcon)
                                        .font(.system(size: 20))
                                    Text("Login with \(biometricName)")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(.primaryStart)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.primaryStart.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                        }
                        
                        // Register Link
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 15))
                                .foregroundColor(.textSecondary)
                            
                            Button(action: { showRegisterView = true }) {
                                Text("Sign Up")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primaryStart)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
                .background(
                    Color.backgroundPrimary
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .ignoresSafeArea()
                )
            }
        }
        .sheet(isPresented: $showRegisterView) {
            RegisterView()
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
    
    // MARK: - Biometric Helpers
    
    private var biometricIcon: String {
        switch viewModel.biometricType() {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.fill"
        }
    }
    
    private var biometricName: String {
        switch viewModel.biometricType() {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Biometrics"
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
