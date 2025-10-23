//
//  AuthViewModel.swift
//  MacroLens
//
//  Path: MacroLens/ViewModels/AuthViewModel.swift
//

import SwiftUI
import LocalAuthentication
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Auth State
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Login Properties
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    @Published var loginEmailError: String?
    @Published var loginPasswordError: String?
    
    // Register Properties
    @Published var registerFirstName = ""
    @Published var registerLastName = ""
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var registerConfirmPassword = ""
    @Published var registerEmailError: String?
    @Published var registerPasswordError: String?
    @Published var registerConfirmPasswordError: String?
    
    // Forgot Password Properties
    @Published var forgotPasswordEmail = ""
    @Published var forgotPasswordEmailError: String?
    
    // MARK: - Dependencies
    private let authService = AuthService.shared
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        checkAuthStatus()
        setupObservers()
    }
    
    // MARK: - Setup
    
    /// Setup observers for authentication state
    private func setupObservers() {
        // Monitor network connectivity
        networkManager.$isOnline
            .sink { [weak self] isOnline in
                if !isOnline {
                    self?.errorMessage = "No internet connection. Please check your network."
                }
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
            Config.Logging.log("User profile loaded successfully", level: .info)
        } catch {
            Config.Logging.log("Failed to load user: \(error)", level: .error)
            // Clear auth if token is invalid
            if case APIError.unauthorized = error {
                logout()
            }
        }
    }
    
    // MARK: - Login Methods
    
    /// Validate login form
    private func validateLoginForm() -> Bool {
        var isValid = true
        
        // Email validation
        let emailResult = ValidationHelper.validateEmail(loginEmail)
        if !emailResult.isValid {
            loginEmailError = emailResult.errorMessage
            isValid = false
        } else {
            loginEmailError = nil
        }
        
        // Password validation (basic check)
        if loginPassword.isEmpty {
            loginPasswordError = "Password is required"
            isValid = false
        } else {
            loginPasswordError = nil
        }
        
        return isValid
    }
    
    /// Login user with email and password
    func login() async {
        clearErrors()
        
        guard validateLoginForm() else { return }
        
        isLoading = true
        
        do {
            let response = try await authService.login(
                email: loginEmail.trimmingCharacters(in: .whitespaces),
                password: loginPassword
            )
            
            user = response.user
            isAuthenticated = true
            successMessage = "Welcome back!"
            
            // Clear form
            clearLoginForm()
            
            Config.Logging.log("User logged in: \(response.user.email)", level: .info)
            
        } catch {
            handleAuthError(error)
            Config.Logging.log("Login failed: \(error)", level: .error)
        }
        
        isLoading = false
    }
    
    /// Login with biometrics (Face ID / Touch ID)
    func loginWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometrics available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            errorMessage = "Biometric authentication not available"
            return false
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Use biometrics to log in to MacroLens"
            )
            
            if success {
                // TODO: Implement biometric login with stored credentials
                // For now, just return success
                Config.Logging.log("Biometric authentication successful", level: .info)
            }
            
            return success
        } catch {
            errorMessage = "Biometric authentication failed"
            Config.Logging.log("Biometric auth failed: \(error)", level: .error)
            return false
        }
    }
    
    /// Get biometric type available on device
    func biometricType() -> LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
    
    // MARK: - Register Methods
    
    /// Validate registration form
    private func validateRegisterForm() -> Bool {
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
    
    /// Calculate password strength
    func getPasswordStrength(_ password: String) -> PasswordStrength {
        return PasswordStrength.calculate(password)
    }
    
    /// Register new user
    func register() async {
        clearErrors()
        
        guard validateRegisterForm() else { return }
        
        isLoading = true
        
        do {
            let response = try await authService.register(
                email: registerEmail.trimmingCharacters(in: .whitespaces),
                password: registerPassword,
                firstName: registerFirstName.isEmpty ? nil : registerFirstName.trimmingCharacters(in: .whitespaces),
                lastName: registerLastName.isEmpty ? nil : registerLastName.trimmingCharacters(in: .whitespaces)
            )
            
            user = response.user
            isAuthenticated = true
            successMessage = "Account created successfully!"
            
            // Clear form
            clearRegisterForm()
            
            Config.Logging.log("User registered: \(response.user.email)", level: .info)
            
        } catch {
            handleAuthError(error)
            Config.Logging.log("Registration failed: \(error)", level: .error)
        }
        
        isLoading = false
    }
    
    // MARK: - Forgot Password Methods
    
    /// Validate forgot password form
    private func validateForgotPasswordForm() -> Bool {
        var isValid = true
        
        if forgotPasswordEmail.isEmpty {
            forgotPasswordEmailError = "Email is required"
            isValid = false
        } else {
            let emailResult = ValidationHelper.validateEmail(forgotPasswordEmail)
            if !emailResult.isValid {
                forgotPasswordEmailError = "Please enter a valid email"
                isValid = false
            } else {
                forgotPasswordEmailError = nil
            }
        }
        
        return isValid
    }
    
    /// Send password reset email
    func resetPassword() async {
        clearErrors()
        
        guard validateForgotPasswordForm() else { return }
        
        isLoading = true
        
        do {
            let request = ResetPasswordRequest(email: forgotPasswordEmail)
            try await authService.resetPassword(request)
            
            successMessage = "Password reset link sent to your email"
            clearForgotPasswordForm()
            
            Config.Logging.log("Password reset requested for: \(forgotPasswordEmail)", level: .info)
            
        } catch {
            handleAuthError(error)
            Config.Logging.log("Password reset failed: \(error)", level: .error)
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    
    /// Logout user
    func logout() {
        Task {
            do {
                try await authService.logout()
                
                // Clear state
                user = nil
                isAuthenticated = false
                clearAllForms()
                
                Config.Logging.log("User logged out successfully", level: .info)
                
            } catch {
                // Even if API call fails, clear local state
                user = nil
                isAuthenticated = false
                clearAllForms()
                
                Config.Logging.log("Logout error (local state cleared): \(error)", level: .warning)
            }
        }
    }
    
    // MARK: - Error Handling
    
    /// Handle authentication errors with user-friendly messages
    private func handleAuthError(_ error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .unauthorized:
                errorMessage = "Invalid email or password"
            case .forbidden:
                errorMessage = "You don't have permission to perform this action"
            case .notFound:
                errorMessage = "Requested resource not found"
            case .validationError(let message):
                errorMessage = message
            case .networkError:
                errorMessage = "Network error. Please check your connection."
            case .serverError:
                errorMessage = "Server error. Please try again later."
            default:
                errorMessage = networkManager.friendlyErrorMessage(error)
            }
        } else {
            errorMessage = "An unexpected error occurred. Please try again."
        }
    }
    
    // MARK: - Form Clearing
    
    /// Clear login form
    private func clearLoginForm() {
        loginEmail = ""
        loginPassword = ""
        loginEmailError = nil
        loginPasswordError = nil
    }
    
    /// Clear register form
    private func clearRegisterForm() {
        registerFirstName = ""
        registerLastName = ""
        registerEmail = ""
        registerPassword = ""
        registerConfirmPassword = ""
        registerEmailError = nil
        registerPasswordError = nil
        registerConfirmPasswordError = nil
    }
    
    /// Clear forgot password form
    private func clearForgotPasswordForm() {
        forgotPasswordEmail = ""
        forgotPasswordEmailError = nil
    }
    
    /// Clear all forms
    private func clearAllForms() {
        clearLoginForm()
        clearRegisterForm()
        clearForgotPasswordForm()
    }
    
    /// Clear all errors
    func clearErrors() {
        errorMessage = nil
        successMessage = nil
        loginEmailError = nil
        loginPasswordError = nil
        registerEmailError = nil
        registerPasswordError = nil
        registerConfirmPasswordError = nil
        forgotPasswordEmailError = nil
    }
    
    /// Clear single error message
    func clearError() {
        errorMessage = nil
        successMessage = nil
    }
}

// MARK: - Password Strength
enum PasswordStrength {
    case weak, medium, strong
    
    var bars: Int {
        switch self {
        case .weak: return 1
        case .medium: return 2
        case .strong: return 3
        }
    }
    
    var color: Color {
        switch self {
        case .weak: return .error
        case .medium: return Color.orange
        case .strong: return .secondary
        }
    }
    
    var text: String {
        switch self {
        case .weak: return "Weak password"
        case .medium: return "Medium password"
        case .strong: return "Strong password"
        }
    }
    
    static func calculate(_ password: String) -> PasswordStrength {
        var score = 0
        
        // Length checks
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        
        // Character variety checks
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil { score += 1 }
        
        // Determine strength
        if score <= 2 { return .weak }
        if score <= 4 { return .medium }
        return .strong
    }
}
