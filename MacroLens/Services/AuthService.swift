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
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "full_name": "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
        ]
        
        // API returns nested response: { success: true, data: { user: {}, tokens: {} } }
        let apiResponse: APIResponse<AuthDataWrapper> = try await networkManager.post(
            endpoint: Config.Endpoints.register,
            parameters: parameters
        )
        
        guard apiResponse.success, let data = apiResponse.data else {
            throw APIError.serverError(apiResponse.error?.message ?? "Registration failed")
        }
        
        // Store tokens
        try saveTokens(
            accessToken: data.tokens.accessToken,
            refreshToken: data.tokens.refreshToken
        )
        
        // Store user info
        try keychain.set(data.user.id, key: Config.StorageKeys.userId)
        try keychain.set(data.user.email, key: Config.StorageKeys.userEmail)
        
        Config.Logging.log("User registered successfully: \(data.user.email)", level: .info)
        
        // Return simplified AuthResponse
        return AuthResponse(
            user: data.user,
            accessToken: data.tokens.accessToken,
            refreshToken: data.tokens.refreshToken,
            tokenType: data.tokens.tokenType,
            expiresIn: data.tokens.expiresIn
        )
    }
    
    // MARK: - Login
    
    /// Login user
    func login(email: String, password: String) async throws -> AuthResponse {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        // API returns nested response
        let apiResponse: APIResponse<AuthDataWrapper> = try await networkManager.post(
            endpoint: Config.Endpoints.login,
            parameters: parameters
        )
        
        guard apiResponse.success, let data = apiResponse.data else {
            throw APIError.unauthorized
        }
        
        // Store tokens
        try saveTokens(
            accessToken: data.tokens.accessToken,
            refreshToken: data.tokens.refreshToken
        )
        
        // Store user info
        try keychain.set(data.user.id, key: Config.StorageKeys.userId)
        try keychain.set(data.user.email, key: Config.StorageKeys.userEmail)
        
        Config.Logging.log("User logged in: \(data.user.email)", level: .info)
        
        return AuthResponse(
            user: data.user,
            accessToken: data.tokens.accessToken,
            refreshToken: data.tokens.refreshToken,
            tokenType: data.tokens.tokenType,
            expiresIn: data.tokens.expiresIn
        )
    }
    
    // MARK: - Get Current User
    
    /// Get current user profile
    func getCurrentUser() async throws -> User {
        let apiResponse: APIResponse<UserDataWrapper> = try await networkManager.get(
            endpoint: Config.Endpoints.currentUser
        )
        
        guard apiResponse.success, let data = apiResponse.data else {
            throw APIError.unauthorized
        }
        
        return data.user
    }
    
    // MARK: - Logout
    
    /// Logout user
    func logout() async throws {
        // Call logout endpoint (optional, API may not have this)
        do {
            let _: APIResponse<EmptyResponse> = try await networkManager.post(
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
        
        let apiResponse: APIResponse<TokenDataWrapper> = try await networkManager.post(
            endpoint: Config.Endpoints.refreshToken,
            parameters: parameters
        )
        
        guard apiResponse.success, let data = apiResponse.data else {
            throw APIError.unauthorized
        }
        
        // Store new tokens
        try saveTokens(
            accessToken: data.tokens.accessToken,
            refreshToken: data.tokens.refreshToken
        )
        
        return data.tokens
    }
    
    /// Save tokens to keychain
    private func saveTokens(accessToken: String, refreshToken: String) throws {
        try keychain.set(accessToken, key: Config.StorageKeys.accessToken)
        try keychain.set(refreshToken, key: Config.StorageKeys.refreshToken)
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
        Config.Logging.log("Auth data cleared", level: .info)
    }
    
    // MARK: - Password Reset
    
    /// Request password reset
    func resetPassword(_ request: ResetPasswordRequest) async throws {
        let parameters: [String: Any] = [
            "email": request.email
        ]
        
        let _: APIResponse<EmptyResponse> = try await networkManager.post(
            endpoint: Config.Endpoints.resetPassword,
            parameters: parameters
        )
    }
}

// MARK: - Helper Response Wrappers
// These match the backend API structure: { success: true, data: { user: {}, tokens: {} } }

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    let error: APIErrorResponse?
}

struct APIErrorResponse: Codable {
    let message: String
    let code: String?
}

struct AuthDataWrapper: Codable {
    let user: User
    let tokens: TokenResponse
}

struct UserDataWrapper: Codable {
    let user: User
}

struct TokenDataWrapper: Codable {
    let tokens: TokenResponse
}

struct EmptyResponse: Codable {}
