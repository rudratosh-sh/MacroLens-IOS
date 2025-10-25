//
//  SocialAuthModels.swift
//  MacroLens
//
//  Path: MacroLens/Models/SocialAuthModels.swift
//
//  Description: Models for social authentication (Google, Apple)
//

import Foundation

// MARK: - Social Auth Provider
enum SocialAuthProvider: String, Codable {
    case google = "google"
    case apple = "apple"
    
    var displayName: String {
        switch self {
        case .google: return "Google"
        case .apple: return "Apple"
        }
    }
}

// MARK: - Social Auth Request
/// Request payload for social authentication
struct SocialAuthRequest: Codable {
    let provider: SocialAuthProvider
    let idToken: String
    let email: String?
    let fullName: String?
    let profileImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case provider
        case idToken = "id_token"
        case email
        case fullName = "full_name"
        case profileImageUrl = "profile_image_url"
    }
}

// MARK: - Social Auth Response
/// Response from social authentication endpoint
struct SocialAuthResponse: Codable {
    let success: Bool
    let message: String?
    let data: SocialAuthData
    
    struct SocialAuthData: Codable {
        let user: User
        let tokens: Token
        let isNewUser: Bool
        
        enum CodingKeys: String, CodingKey {
            case user
            case tokens
            case isNewUser = "is_new_user"
        }
    }
}

// MARK: - Google User Info
/// Parsed user information from Google Sign In
struct GoogleUserInfo {
    let idToken: String
    let email: String
    let fullName: String?
    let givenName: String?
    let familyName: String?
    let profileImageUrl: String?
}

// MARK: - Apple User Info
/// Parsed user information from Apple Sign In
struct AppleUserInfo {
    let identityToken: String
    let authorizationCode: String?
    let email: String?
    let fullName: String?
    let givenName: String?
    let familyName: String?
}

// MARK: - Social Auth Error
enum SocialAuthError: LocalizedError {
    case cancelled
    case noIdentityToken
    case noEmail
    case invalidCredential
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Authentication was cancelled"
        case .noIdentityToken:
            return "Failed to get identity token"
        case .noEmail:
            return "Email is required for authentication"
        case .invalidCredential:
            return "Invalid authentication credential"
        case .networkError:
            return "Network error during authentication"
        case .unknown(let error):
            return "Authentication failed: \(error.localizedDescription)"
        }
    }
}
