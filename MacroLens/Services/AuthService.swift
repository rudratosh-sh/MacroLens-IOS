//
//  AuthService.swift
//  MacroLens
//
//  Path: MacroLens/Services/AuthService.swift
//
//  Description: Service layer for authentication operations with backend API
//

import Foundation
import KeychainAccess

/// Service for handling authentication operations
final class AuthService: @unchecked Sendable {
    
    // MARK: - Singleton
    static let shared = AuthService()
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private let keychain = Keychain(service: Config.App.bundleIdentifier)
    private let biometricManager = BiometricAuthManager.shared
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Registration
    
    /// Register new user with full name
    /// - Parameters:
    ///   - email: User email address
    ///   - password: User password (must meet strength requirements)
    ///   - fullName: User's full name
    /// - Returns: AuthResponse with user data and tokens
    /// - Throws: APIError on failure
    func register(
        email: String,
        password: String,
        fullName: String
    ) async throws -> AuthResponse {
        let request = RegisterRequest(
            email: email,
            password: password,
            fullName: fullName
        )
        
        let parameters: [String: Any] = [
            "email": request.email,
            "password": request.password,
            "full_name": request.fullName
        ]
        
        let response: AuthResponse = try await networkManager.post(
            endpoint: Config.Endpoints.register,
            parameters: parameters
        )
        
        // Save tokens
        try saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            userId: response.user.id,
            userEmail: response.user.email
        )
        
        Config.Logging.log("User registered successfully: \(response.user.email)", level: .info)
        
        return response
    }
    
    // MARK: - Login
    
    /// Login user with email and password
    /// - Parameters:
    ///   - email: User email address
    ///   - password: User password
    /// - Returns: AuthResponse with user data and tokens
    /// - Throws: APIError on failure
    func login(
        email: String,
        password: String
    ) async throws -> AuthResponse {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let response: AuthResponse = try await networkManager.post(
            endpoint: Config.Endpoints.login,
            parameters: parameters
        )
        
        // Save tokens
        try saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            userId: response.user.id,
            userEmail: response.user.email
        )
        
        Config.Logging.log("User logged in successfully: \(response.user.email)", level: .info)
        
        return response
    }
    
    // MARK: - Biometric Login
    
    /// Login using biometric authentication
    /// - Returns: AuthResponse with user data and tokens
    /// - Throws: BiometricError or APIError
    func loginWithBiometrics() async throws -> AuthResponse {
        // Authenticate with biometrics
        let email = try await biometricManager.authenticateWithBiometrics()
        
        // For biometric login, we need to use stored refresh token or session
        // Since we don't store password, we use existing tokens
        guard let storedRefreshToken = try? keychain.get(Config.StorageKeys.refreshToken) else {
            throw BiometricError.notEnrolled
        }
        _ = storedRefreshToken // silence unused variable if not used directly
        
        // Refresh token to get new access token
        let response = try await refreshToken()
        
        Config.Logging.log("User logged in with biometrics: \(email)", level: .info)
        
        return AuthResponse(
            user: try await getCurrentUser(),
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            tokenType: response.tokenType,
            expiresIn: response.expiresIn
        )
    }
    
    /// Enable biometric login after successful password login
    /// - Parameter email: User email to store
    /// - Throws: KeychainAccess.Status on failure
    @MainActor
    func enableBiometricLogin(email: String) throws {
        try biometricManager.enableBiometric(email: email)
    }
    
    // MARK: - Logout
    
    /// Logout user and clear all stored data
    /// - Throws: APIError on network failure (non-critical)
    func logout() async throws {
        do {
            // Call backend logout endpoint
            let _: [String: String] = try await networkManager.post(
                endpoint: Config.Endpoints.logout,
                parameters: [:]
            )
        } catch {
            Config.Logging.log("Logout API call failed: \(error)", level: .warning)
            // Continue with local cleanup even if API fails
        }
        
        // Clear local auth data
        clearAuthData()
        
        Config.Logging.log("User logged out successfully", level: .info)
    }
    
    // MARK: - Token Refresh
    
    /// Refresh access token using refresh token
    /// - Returns: New token response
    /// - Throws: APIError if refresh fails
    func refreshToken() async throws -> TokenResponse {
        guard let refreshToken = try? keychain.get(Config.StorageKeys.refreshToken) else {
            throw APIError.unauthorized
        }
        
        let parameters: [String: Any] = [
            "refresh_token": refreshToken
        ]
        
        let response: TokenResponse = try await networkManager.post(
            endpoint: Config.Endpoints.refreshToken,
            parameters: parameters
        )
        
        // Update tokens
        try saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        Config.Logging.log("Access token refreshed", level: .info)
        
        return response
    }
    
    // MARK: - Email Verification
    
    /// Verify email with token
    /// - Parameter token: Verification token from email
    /// - Throws: APIError on failure
    func verifyEmail(token: String) async throws {
        let parameters: [String: Any] = [
            "token": token
        ]
        
        let _: [String: String] = try await networkManager.post(
            endpoint: Config.Endpoints.verifyEmail,
            parameters: parameters
        )
        
        Config.Logging.log("Email verified successfully", level: .info)
    }
    
    // MARK: - Password Reset
    
    /// Request password reset email
    /// - Parameter email: User email address
    /// - Throws: APIError on failure
    func requestPasswordReset(email: String) async throws {
        let parameters: [String: Any] = [
            "email": email
        ]
        
        let _: [String: String] = try await networkManager.post(
            endpoint: Config.Endpoints.resetPassword,
            parameters: parameters
        )
        
        Config.Logging.log("Password reset requested for: \(email)", level: .info)
    }
    
    /// Reset password with token
    /// - Parameters:
    ///   - token: Reset token from email
    ///   - newPassword: New password
    /// - Throws: APIError on failure
    func resetPassword(token: String, newPassword: String) async throws {
        let parameters: [String: Any] = [
            "token": token,
            "new_password": newPassword
        ]
        
        let _: [String: String] = try await networkManager.post(
            endpoint: Config.Endpoints.resetPassword,
            parameters: parameters
        )
        
        Config.Logging.log("Password reset successfully", level: .info)
    }
    
    // MARK: - Get Current User
    
    /// Get current user profile
    /// - Returns: User object
    /// - Throws: APIError if unauthorized or network error
    func getCurrentUser() async throws -> User {
        let user: User = try await networkManager.get(
            endpoint: Config.Endpoints.userProfile
        )
        
        return user
    }
    
    // MARK: - Token Management
    
    /// Save authentication tokens to keychain
    /// - Parameters:
    ///   - accessToken: JWT access token
    ///   - refreshToken: JWT refresh token
    ///   - userId: Optional user ID
    ///   - userEmail: Optional user email
    /// - Throws: KeychainAccess.Status on failure
    private func saveTokens(
        accessToken: String,
        refreshToken: String,
        userId: String? = nil,
        userEmail: String? = nil
    ) throws {
        try keychain.set(accessToken, key: Config.StorageKeys.accessToken)
        try keychain.set(refreshToken, key: Config.StorageKeys.refreshToken)
        
        if let userId = userId {
            try keychain.set(userId, key: Config.StorageKeys.userId)
        }
        
        if let userEmail = userEmail {
            try keychain.set(userEmail, key: Config.StorageKeys.userEmail)
        }
        
        // Update APIClient tokens
        APIClient.shared.accessToken = accessToken
        APIClient.shared.refreshToken = refreshToken
    }
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        guard let accessToken = try? keychain.get(Config.StorageKeys.accessToken) else {
            return false
        }
        return !accessToken.isEmpty
    }
    
    /// Get stored user ID
    var userId: String? {
        return try? keychain.get(Config.StorageKeys.userId)
    }
    
    /// Get stored user email
    var userEmail: String? {
        return try? keychain.get(Config.StorageKeys.userEmail)
    }
    
    /// Clear all authentication data
    func clearAuthData() {
        try? keychain.remove(Config.StorageKeys.accessToken)
        try? keychain.remove(Config.StorageKeys.refreshToken)
        try? keychain.remove(Config.StorageKeys.userId)
        try? keychain.remove(Config.StorageKeys.userEmail)
        
        // Clear biometric data (must run on main actor)
        Task { @MainActor in
            biometricManager.disableBiometric()
        }
        
        // Clear API client tokens
        APIClient.shared.clearTokens()
    }
}
