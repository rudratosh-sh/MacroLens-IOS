//
//  AuthViewModel.swift
//  MacroLens
//
//  Path: MacroLens/ViewModels/AuthViewModel.swift
//

import Foundation
import SwiftUI
import LocalAuthentication
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Login form
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    
    // Register form
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var registerConfirmPassword = ""
    @Published var registerFirstName = ""
    @Published var registerLastName = ""
    
    // Validation errors
    @Published var loginEmailError: String?
    @Published var loginPasswordError: String?
    @Published var registerEmailError: String?
    @Published var registerPasswordError: String?
    @Published var registerConfirmPasswordError: String?
    
    // MARK: - Properties
    private let authService = AuthService.shared
    
    // MARK: - Initialization
    init() {
        checkAuthStatus()
    }
    
    // MARK: - Auth Status
    
    /// Check if user is already authenticated
    func checkAuthStatus() {
        isAuthenticated = authService.isAuthenticated
        
        if isAuthenticated {
            Task {
                await loadCurrentUser()
            }
        }
    }
    
    /// Load current user profile
    func loadCurrentUser() async {
        do {
            user = try await authService.getCurrentUser()
            isAuthenticated = true
            Config.Logging.log("User profile loaded", level: .info)
        } catch {
            Config.Logging.log("Failed to load user: \(error)", level: .error)
            // Clear auth if token is invalid
            if case APIError.unauthorized = error {
                logout()
            }
        }
    }
    
    // MARK: - Login
    
    /// Validate login form
    func validateLoginForm() -> Bool {
        var isValid = true
        
        // Email validation
        let emailResult = ValidationHelper.validateEmail(loginEmail)
        if !emailResult.isValid {
            loginEmailError = emailResult.errorMessage
            isValid = false
        } else {
            loginEmailError = nil
        }
        
        // Password validation
        if loginPassword.isEmpty {
            loginPasswordError = "Password is required"
            isValid = false
        } else {
            loginPasswordError = nil
        }
        
        return isValid
    }
    
    /// Login user
    func login() async {
        guard validateLoginForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.login(
                email: loginEmail.trimmingCharacters(in: .whitespaces),
                password: loginPassword
            )
            
            user = response.user
            isAuthenticated = true
            
            // Clear form
            clearLoginForm()
            
        } catch {
            errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            Config.Logging.log("Login failed: \(error)", level: .error)
        }
        
        isLoading = false
    }
    
    // MARK: - Register
    
    /// Validate registration form
    func validateRegisterForm() -> Bool {
        var isValid = true
        
        // Email validation
        let emailResult = ValidationHelper.validateEmail(registerEmail)
        if !emailResult.isValid {
            registerEmailError = emailResult.errorMessage
            isValid = false
        } else {
            registerEmailError = nil
        }
        
        // Password validation
        let passwordResult = ValidationHelper.validatePassword(registerPassword)
        if !passwordResult.isValid {
            registerPasswordError = passwordResult.errorMessage
            isValid = false
        } else {
            registerPasswordError = nil
        }
        
        // Confirm password validation
        let confirmResult = ValidationHelper.validatePasswordMatch(
            registerPassword,
            registerConfirmPassword
        )
        if !confirmResult.isValid {
            registerConfirmPasswordError = confirmResult.errorMessage
            isValid = false
        } else {
            registerConfirmPasswordError = nil
        }
        
        return isValid
    }
    
    /// Register new user
    func register() async {
        guard validateRegisterForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.register(
                email: registerEmail.trimmingCharacters(in: .whitespaces),
                password: registerPassword,
                firstName: registerFirstName.isEmpty ? nil : registerFirstName,
                lastName: registerLastName.isEmpty ? nil : registerLastName
            )
            
            user = response.user
            isAuthenticated = true
            
            // Clear form
            clearRegisterForm()
            
        } catch {
            errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            Config.Logging.log("Registration failed: \(error)", level: .error)
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    
    /// Logout user
    func logout() {
        Task {
            do {
                try await authService.logout()
            } catch {
                Config.Logging.log("Logout error: \(error)", level: .warning)
            }
            
            user = nil
            isAuthenticated = false
            clearAllForms()
        }
    }
    
    // MARK: - Biometric Authentication
    
    /// Check if biometric authentication is available
    func biometricType() -> LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    /// Login with biometric authentication
    func loginWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            errorMessage = "Biometric authentication not available"
            return false
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Login to MacroLens"
            )
            
            if success {
                await loadCurrentUser()
            }
            
            return success
        } catch {
            errorMessage = "Biometric authentication failed"
            return false
        }
    }
    
    // MARK: - Form Management
    
    private func clearLoginForm() {
        loginEmail = ""
        loginPassword = ""
        loginEmailError = nil
        loginPasswordError = nil
    }
    
    private func clearRegisterForm() {
        registerEmail = ""
        registerPassword = ""
        registerConfirmPassword = ""
        registerFirstName = ""
        registerLastName = ""
        registerEmailError = nil
        registerPasswordError = nil
        registerConfirmPasswordError = nil
    }
    
    private func clearAllForms() {
        clearLoginForm()
        clearRegisterForm()
        errorMessage = nil
    }
    
    // MARK: - Error Handling
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}
