//
//  AuthModels.swift
//  MacroLens
//
//  Path: MacroLens/Models/AuthModels.swift
//

import Foundation

// MARK: - Login Request
struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
}

// MARK: - Register Request
struct RegisterRequest: Codable, Sendable {
    let email: String
    let password: String
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case fullName = "full_name"
    }
}

// MARK: - Auth Response
struct AuthResponse: Codable, Sendable {
    let user: User
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

// MARK: - Token Refresh Request
struct RefreshTokenRequest: Codable, Sendable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

// MARK: - Token Response
struct TokenResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

// MARK: - Verify Email Request
struct VerifyEmailRequest: Codable, Sendable {
    let token: String
}

// MARK: - Reset Password Request
struct ResetPasswordRequest: Codable, Sendable {
    let email: String
}

// MARK: - Reset Password Confirm
struct ResetPasswordConfirmRequest: Codable, Sendable {
    let token: String
    let newPassword: String
    
    enum CodingKeys: String, CodingKey {
        case token
        case newPassword = "new_password"
    }
}

// MARK: - Change Password Request
struct ChangePasswordRequest: Codable, Sendable {
    let currentPassword: String
    let newPassword: String
    
    enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case newPassword = "new_password"
    }
}

// MARK: - Biometric Login Request
struct BiometricLoginRequest: Codable, Sendable {
    let email: String
    let biometricToken: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case biometricToken = "biometric_token"
    }
}
