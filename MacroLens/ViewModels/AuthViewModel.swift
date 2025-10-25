//
//  AuthViewModel.swift
//  MacroLens
//
//  Path: MacroLens/ViewModels/AuthViewModel.swift
//
//  Description: ViewModel managing authentication state and user interactions
//

import Foundation
import SwiftUI
import LocalAuthentication
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Authentication State
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Login Form
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    
    // Register Form
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var registerConfirmPassword = ""
    @Published var registerFullName = ""
    @Published var acceptedTerms = false
    
    // Validation Errors
    @Published var loginEmailError: String?
    @Published var loginPasswordError: String?
    @Published var registerEmailError: String?
    @Published var registerPasswordError: String?
    @Published var registerConfirmPasswordError: String?
    @Published var registerFullNameError: String?
    
    // Biometric State
    @Published var showBiometricPrompt = false
    
    // MARK: - Properties
    
    private let authService = AuthService.shared
    private let biometricManager = BiometricAuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var canUseBiometric: Bool {
        return biometricManager.isBiometricAvailable() &&
               biometricManager.isBiometricEnabled()
    }
    
    var passwordStrength: PasswordStrength {
        return ValidationHelper.getPasswordStrength(registerPassword)
    }
    
    // MARK: - Initialization
    
    init() {
        checkAuthStatus()
        setupValidation()
    }
    
    // MARK: - Setup
    
    /// Setup real-time form validation
    private func setupValidation() {
        // Login email validation
        $loginEmail
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self, !email.isEmpty else { return }
                let result = ValidationHelper.validateEmail(email)
                self.loginEmailError = result.isValid ? nil : result.errorMessage
            }
            .store(in: &cancellables)
        
        // Register email validation
        $registerEmail
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self, !email.isEmpty else { return }
                let result = ValidationHelper.validateEmail(email)
                self.registerEmailError = result.isValid ? nil : result.errorMessage
            }
            .store(in: &cancellables)
        
        // Register password validation
        $registerPassword
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self, !password.isEmpty else { return }
                let result = ValidationHelper.validatePassword(password)
                self.registerPasswordError = result.isValid ? nil : result.errorMessage
            }
            .store(in: &cancellables)
        
        // Register confirm password validation
        $registerConfirmPassword
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] confirmPassword in
                guard let self = self, !confirmPassword.isEmpty else { return }
                let result = ValidationHelper.validatePasswordMatch(
                    self.registerPassword,
                    confirmPassword
                )
                self.registerConfirmPasswordError = result.isValid ? nil : result.errorMessage
            }
            .store(in: &cancellables)
        
        // Full name validation
        $registerFullName
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] name in
                guard let self = self, !name.isEmpty else { return }
                let result = ValidationHelper.validateFullName(name)
                self.registerFullNameError = result.isValid ? nil : result.errorMessage
            }
            .store(in: &cancellables)
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
    /// - Returns: Boolean indicating if form is valid
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
        } else if loginPassword.count < 8 {
            loginPasswordError = "Password must be at least 8 characters"
            isValid = false
        } else {
            loginPasswordError = nil
        }
        
        return isValid
    }
    
    /// Login user with email and password
    /// Login user
    func login() async {
        guard validateLoginForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, _) = try await authService.login(
                email: loginEmail.trimmingCharacters(in: .whitespaces),
                password: loginPassword
            )
            
            self.user = user
            isAuthenticated = true
            
            // Prompt to enable biometric after successful login
            if biometricType() != .none && !authService.isBiometricEnabled {
                // Ask user if they want to enable biometric login
                // This will be handled in LoginView with an alert
            }
            
            // Clear form (don't clear password yet if we need to save for biometric)
            loginEmail = ""
            
        } catch {
            errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            Config.Logging.log("Login failed: \(error)", level: .error)
        }
        
        isLoading = false
    }
    
    // MARK: - Biometric Login
    
    /// Get biometric type for UI display
    /// - Returns: LABiometryType
    func biometricType() -> LABiometryType {
        return biometricManager.biometricType()
    }
    
    /// Get biometric display name
    /// - Returns: User-friendly name
    func biometricDisplayName() -> String {
        return biometricManager.biometricDisplayName()
    }
    
    /// Login with biometric authentication
    func loginWithBiometrics() async -> Bool {
        // ✅ FIX: Check if biometric is enabled first
        guard authService.isBiometricEnabled else {
            errorMessage = "Biometric login is not enabled. Please log in with email and password first."
            return false
        }
        
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            errorMessage = "Biometric authentication is not available on this device"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // ✅ FIX: First authenticate with biometrics
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Login to MacroLens"
            )
            
            guard success else {
                isLoading = false
                return false
            }
            
            // ✅ FIX: Then retrieve stored credentials
            guard let credentials = try authService.getBiometricCredentials() else {
                errorMessage = "No saved credentials. Please log in with email and password."
                isLoading = false
                return false
            }
            
            // ✅ FIX: Actually perform login with retrieved credentials
            let (authenticatedUser, _) = try await authService.login(
                email: credentials.email,
                password: credentials.password
            )
            
            user = authenticatedUser
            isAuthenticated = true
            
            Config.Logging.log("Biometric login successful", level: .info)
            isLoading = false
            return true
            
        } catch let error as LAError {
            // Handle biometric-specific errors
            switch error.code {
            case .userCancel:
                errorMessage = nil // User cancelled, don't show error
            case .userFallback:
                errorMessage = "Please log in with email and password"
            case .biometryLockout:
                errorMessage = "Too many failed attempts. Please try again later."
            case .biometryNotEnrolled:
                errorMessage = "Face ID/Touch ID is not set up. Please enable it in Settings."
            default:
                errorMessage = "Biometric authentication failed"
            }
            isLoading = false
            return false
            
        } catch {
            errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            Config.Logging.log("Biometric login failed: \(error)", level: .error)
            isLoading = false
            return false
        }
    }

    /// Enable biometric authentication (save credentials)
    func enableBiometric(email: String, password: String) async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            errorMessage = "Biometric authentication is not available"
            return false
        }
        
        do {
            // Authenticate to confirm user consent
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Enable \(biometricType() == .faceID ? "Face ID" : "Touch ID") for quick sign-in"
            )
            
            guard success else { return false }
            
            // Save credentials
            try authService.saveBiometricCredentials(email: email, password: password)
            
            Config.Logging.log("Biometric authentication enabled", level: .info)
            return true
            
        } catch {
            errorMessage = "Failed to enable biometric login"
            return false
        }
    }

    /// Disable biometric authentication
    func disableBiometric() {
        authService.disableBiometric()
    }
    
    /// Skip biometric enrollment
    func skipBiometricEnrollment() {
        biometricManager.markPromptShown()
        showBiometricPrompt = false
    }
    
    // MARK: - Register
    
    /// Validate registration form
    /// - Returns: Boolean indicating if form is valid
    func validateRegisterForm() -> Bool {
        var isValid = true
        
        // Full name validation
        let nameResult = ValidationHelper.validateFullName(registerFullName)
        if !nameResult.isValid {
            registerFullNameError = nameResult.errorMessage
            isValid = false
        } else {
            registerFullNameError = nil
        }
        
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
        
        // Terms acceptance
        if !acceptedTerms {
            errorMessage = "Please accept the Terms & Conditions"
            isValid = false
        }
        
        return isValid
    }
    
    /// Register new user
    func register() async {
        guard validateRegisterForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, _) = try await authService.register(
                email: registerEmail.trimmingCharacters(in: .whitespaces),
                password: registerPassword,
                fullName: registerFullName.trimmingCharacters(in: .whitespaces)
            )
            
            self.user = user
            isAuthenticated = true
            
            // Prompt for biometric enrollment if available
            if biometricManager.shouldPromptForEnrollment() {
                showBiometricPrompt = true
            }
            
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
                Config.Logging.log("Logout successful", level: .info)
            } catch {
                Config.Logging.log("Logout error: \(error)", level: .warning)
                // Don't show error to user - always clear local data
            }
            
            await MainActor.run {
                user = nil
                isAuthenticated = false
                clearAllForms()
            }
        }
    }
    
    // MARK: - Form Management
    
    /// Clear login form
    private func clearLoginForm() {
        loginEmail = ""
        loginPassword = ""
        loginEmailError = nil
        loginPasswordError = nil
    }
    
    /// Clear registration form
    private func clearRegisterForm() {
        registerEmail = ""
        registerPassword = ""
        registerConfirmPassword = ""
        registerFullName = ""
        acceptedTerms = false
        registerEmailError = nil
        registerPasswordError = nil
        registerConfirmPasswordError = nil
        registerFullNameError = nil
    }
    
    /// Clear all forms
    private func clearAllForms() {
        clearLoginForm()
        clearRegisterForm()
        errorMessage = nil
    }
    
    /// Enable biometric login for current user
    func enableBiometricLogin() {
        guard let email = authService.userEmail else {
            errorMessage = "Unable to enable biometric login"
            return
        }
        
        do {
            try authService.enableBiometricLogin(email: email)
            showBiometricPrompt = false
            Config.Logging.log("Biometric login enabled", level: .info)
        } catch {
            errorMessage = "Failed to enable biometric login"
            Config.Logging.log("Enable biometric failed: \(error)", level: .error)
        }
    }
    
    // MARK: - Error Handling
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Social Logins
extension AuthViewModel {
    
    /// Sign in with Google
    func loginWithGoogle(presentingViewController: UIViewController) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, _) = try await SocialAuthService.shared.signInWithGoogle(
                presentingViewController: presentingViewController
            )
            await MainActor.run {
                self.user = user
                self.isAuthenticated = true
            }
            Config.Logging.log("Google login successful", level: .info)
        } catch {
            await MainActor.run {
                self.errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            }
            Config.Logging.log("Google login failed: \(error)", level: .error)
        }
        
        await MainActor.run { self.isLoading = false }
    }
    
    /// Sign in with Apple
    func loginWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, _) = try await SocialAuthService.shared.signInWithApple()
            await MainActor.run {
                self.user = user
                self.isAuthenticated = true
            }
            Config.Logging.log("Apple login successful", level: .info)
        } catch {
            await MainActor.run {
                self.errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            }
            Config.Logging.log("Apple login failed: \(error)", level: .error)
        }
        
        await MainActor.run { self.isLoading = false }
    }
}
