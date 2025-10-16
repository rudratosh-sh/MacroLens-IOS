//
//  AuthService.swift
//  MacroLens
//
//  Path: MacroLens/Services/AuthService.swift
//

import Foundation
import KeychainAccess

class AuthService {
    
    // MARK: - Singleton
    static let shared = AuthService()
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private let keychain = Keychain(service: Config.App.bundleIdentifier)
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Registration
    
    /// Register new user
    func register(
        email: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil
    ) async throws -> AuthResponse {
        let request = RegisterRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "first_name": firstName ?? "",
            "last_name": lastName ?? ""
        ]
        
        let response: AuthResponse = try await networkManager.post(
            endpoint: Config.Endpoints.register,
            parameters: parameters
        )
        
        // Store tokens
        try saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        // Store user ID
        try keychain.set(response.user.id, key: Config.StorageKeys.userId)
        try keychain.set(response.user.email, key: Config.StorageKeys.userEmail)
        
        Config.Logging.log("User registered successfully: \(response.user.email)", level: .info)
        
        return response
    }
    
    // MARK: - Login
    
    /// Login user
    func login(email: String, password: String) async throws -> AuthResponse {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let response: AuthResponse = try await networkManager.post(
            endpoint: Config.Endpoints.login,
            parameters: parameters
        )
        
        // Store tokens
        try saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        // Store user ID
        try keychain.set(response.user.id, key: Config.StorageKeys.userId)
        try keychain.set(response.user.email, key: Config.StorageKeys.userEmail)
        
        Config.Logging.log("User logged in: \(response.user.email)", level: .info)
        
        return response
    }
    
    // MARK: - Logout
    
    /// Logout user
    func logout() async throws {
        // Call logout endpoint
        do {
            let _: [String: String] = try await networkManager.post(
                endpoint: Config.Endpoints.logout,
                parameters: [:]
            )
        } catch {
            Config.Logging.log("Logout API call failed: \(error)", level: .warning)
            // Continue with local logout even if API fails
        }
        
        // Clear tokens and user data
        clearAuthData()
        
        Config.Logging.log("User logged out", level: .info)
    }
    
    // MARK: - Token Refresh
    
    /// Refresh access token
    func refreshAccessToken() async throws -> TokenResponse {
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
    func getCurrentUser() async throws -> User {
        let user: User = try await networkManager.get(
            endpoint: Config.Endpoints.userProfile
        )
        
        return user
    }
    
    // MARK: - Token Management
    
    /// Save tokens to keychain
    private func saveTokens(accessToken: String, refreshToken: String) throws {
        try keychain.set(accessToken, key: Config.StorageKeys.accessToken)
        try keychain.set(refreshToken, key: Config.StorageKeys.refreshToken)
        
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
    
    /// Clear all auth data
    func clearAuthData() {
        try? keychain.remove(Config.StorageKeys.accessToken)
        try? keychain.remove(Config.StorageKeys.refreshToken)
        try? keychain.remove(Config.StorageKeys.userId)
        try? keychain.remove(Config.StorageKeys.userEmail)
        
        APIClient.shared.clearTokens()
    }
}
