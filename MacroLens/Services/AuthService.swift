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
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        return (try? keychain.get(Config.StorageKeys.accessToken)) != nil
    }
    
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
        let fullName = "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "full_name": fullName.isEmpty ? email : fullName
        ]
        
        // Backend returns: { success: true, data: { user: {...}, tokens: {...} } }
        let authData: AuthDataResponse = try await networkManager.post(
            endpoint: Config.Endpoints.register,
            parameters: parameters
        )
        
        // Store tokens
        try saveTokens(
            accessToken: authData.tokens.accessToken,
            refreshToken: authData.tokens.refreshToken
        )
        
        // Store user info
        try keychain.set(authData.user.id, key: Config.StorageKeys.userId)
        try keychain.set(authData.user.email, key: Config.StorageKeys.userEmail)
        
        Config.Logging.log("User registered successfully: \(authData.user.email)", level: .info)
        
        // Convert to AuthResponse for ViewModel
        return AuthResponse(
            user: authData.user,
            accessToken: authData.tokens.accessToken,
            refreshToken: authData.tokens.refreshToken,
            tokenType: authData.tokens.tokenType,
            expiresIn: authData.tokens.expiresIn
        )
    }
    
    // MARK: - Login
    
    /// Login user
    func login(email: String, password: String) async throws -> AuthResponse {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        let authData: AuthDataResponse = try await networkManager.post(
            endpoint: Config.Endpoints.login,
            parameters: parameters
        )
        
        // Store tokens
        try saveTokens(
            accessToken: authData.tokens.accessToken,
            refreshToken: authData.tokens.refreshToken
        )
        
        // Store user info
        try keychain.set(authData.user.id, key: Config.StorageKeys.userId)
        try keychain.set(authData.user.email, key: Config.StorageKeys.userEmail)
        
        Config.Logging.log("User logged in: \(authData.user.email)", level: .info)
        
        return AuthResponse(
            user: authData.user,
            accessToken: authData.tokens.accessToken,
            refreshToken: authData.tokens.refreshToken,
            tokenType: authData.tokens.tokenType,
            expiresIn: authData.tokens.expiresIn
        )
    }
    
    // MARK: - Get Current User
    
    /// Get current user profile
    func getCurrentUser() async throws -> User {
        // Backend endpoint is /auth/me which returns: { success: true, data: { user: {...} } }
        let userData: UserDataResponse = try await networkManager.get(
            endpoint: "/auth/me"  // Using direct path since Config.Endpoints doesn't have currentUser
        )
        
        return userData.user
    }
    
    // MARK: - Logout
    
    /// Logout user
    func logout() async throws {
        // Call logout endpoint
        do {
            let _: EmptyDataResponse = try await networkManager.post(
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
    
    // MARK: - Token Management
    
    /// Refresh access token
    func refreshAccessToken() async throws -> TokenResponse {
        guard let refreshToken = try? keychain.get(Config.StorageKeys.refreshToken) else {
            throw APIError.unauthorized
        }
        
        let parameters: [String: Any] = [
            "refresh_token": refreshToken
        ]
        
        // Backend returns: { success: true, data: { tokens: {...} } }
        let tokenData: TokenDataResponse = try await networkManager.post(
            endpoint: Config.Endpoints.refreshToken,
            parameters: parameters
        )
        
        // Store new tokens
        try saveTokens(
            accessToken: tokenData.tokens.accessToken,
            refreshToken: tokenData.tokens.refreshToken
        )
        
        Config.Logging.log("Access token refreshed", level: .info)
        
        return TokenResponse(
            accessToken: tokenData.tokens.accessToken,
            refreshToken: tokenData.tokens.refreshToken,
            tokenType: tokenData.tokens.tokenType,
            expiresIn: tokenData.tokens.expiresIn
        )
    }
    
    /// Save tokens to keychain
    private func saveTokens(accessToken: String, refreshToken: String) throws {
        try keychain.set(accessToken, key: Config.StorageKeys.accessToken)
        try keychain.set(refreshToken, key: Config.StorageKeys.refreshToken)
        
        // Update APIClient tokens
        APIClient.shared.accessToken = accessToken
        APIClient.shared.refreshToken = refreshToken
        
        Config.Logging.log("Tokens saved to keychain", level: .debug)
    }
    
    /// Get access token
    func getAccessToken() -> String? {
        return try? keychain.get(Config.StorageKeys.accessToken)
    }
    
    /// Clear all auth data
    func clearAuthData() {
        try? keychain.remove(Config.StorageKeys.accessToken)
        try? keychain.remove(Config.StorageKeys.refreshToken)
        try? keychain.remove(Config.StorageKeys.userId)
        try? keychain.remove(Config.StorageKeys.userEmail)
        
        // Clear APIClient tokens
        APIClient.shared.clearTokens()
        
        Config.Logging.log("Auth data cleared", level: .info)
    }
    
    // MARK: - Password Reset
    
    /// Request password reset
    func resetPassword(_ request: ResetPasswordRequest) async throws {
        let parameters: [String: Any] = [
            "email": request.email
        ]
        
        let _: EmptyDataResponse = try await networkManager.post(
            endpoint: Config.Endpoints.resetPassword,
            parameters: parameters
        )
        
        Config.Logging.log("Password reset requested for: \(request.email)", level: .info)
    }
    
    /// Verify email with token
    func verifyEmail(_ request: VerifyEmailRequest) async throws {
        let parameters: [String: Any] = [
            "token": request.token
        ]
        
        let _: EmptyDataResponse = try await networkManager.post(
            endpoint: Config.Endpoints.verifyEmail,
            parameters: parameters
        )
        
        Config.Logging.log("Email verified successfully", level: .info)
    }
}
