//
//  ErrorResponse.swift
//  MacroLens
//
//  Path: MacroLens/Models/ErrorResponse.swift
//
//  DEPENDENCIES:
//  - None
//
//  USED BY:
//  - APIClient
//  - NetworkManager
//  - All API services
//
//  PURPOSE:
//  - Standardized API error response model
//  - Parse backend error messages
//  - User-friendly error display
//

import Foundation

// MARK: - Error Response

/// Standard API error response
struct ErrorResponse: Codable, Error, LocalizedError {
    let success: Bool
    let message: String
    let errors: [FieldError]?
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case errors
        case code
    }
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        return message
    }
    
    var failureReason: String? {
        if let errors = errors, !errors.isEmpty {
            return errors.map { $0.message }.joined(separator: ", ")
        }
        return message
    }
}

// MARK: - Field Error

/// Individual field validation error
struct FieldError: Codable {
    let field: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case field
        case message
    }
}

// MARK: - Common Error Codes

extension ErrorResponse {
    
    /// Common API error codes
    enum ErrorCode: String {
        case invalidCredentials = "INVALID_CREDENTIALS"
        case emailAlreadyExists = "EMAIL_ALREADY_EXISTS"
        case userNotFound = "USER_NOT_FOUND"
        case invalidToken = "INVALID_TOKEN"
        case tokenExpired = "TOKEN_EXPIRED"
        case validationError = "VALIDATION_ERROR"
        case serverError = "SERVER_ERROR"
        case networkError = "NETWORK_ERROR"
        case unauthorized = "UNAUTHORIZED"
        case forbidden = "FORBIDDEN"
        case notFound = "NOT_FOUND"
        case rateLimitExceeded = "RATE_LIMIT_EXCEEDED"
        case unknown = "UNKNOWN"
    }
    
    /// Check if error matches specific code
    func isErrorCode(_ errorCode: ErrorCode) -> Bool {
        return code == errorCode.rawValue
    }
}

// MARK: - Error Response Extensions

extension ErrorResponse {
    
    /// Get user-friendly error message
    var userFriendlyMessage: String {
        guard let code = code, let errorCode = ErrorCode(rawValue: code) else {
            return message
        }
        
        switch errorCode {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .emailAlreadyExists:
            return "This email is already registered. Please sign in instead."
        case .userNotFound:
            return "Account not found. Please check your email."
        case .invalidToken:
            return "Your session has expired. Please sign in again."
        case .tokenExpired:
            return "Your session has expired. Please sign in again."
        case .validationError:
            return errors?.first?.message ?? "Please check your input and try again."
        case .serverError:
            return "Server error. Please try again later."
        case .networkError:
            return "Network connection failed. Please check your internet."
        case .unauthorized:
            return "You need to sign in to access this feature."
        case .forbidden:
            return "You don't have permission to perform this action."
        case .notFound:
            return "The requested resource was not found."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
    
    /// Check if error is authentication related
    var isAuthError: Bool {
        guard let code = code else { return false }
        return [
            ErrorCode.invalidCredentials.rawValue,
            ErrorCode.invalidToken.rawValue,
            ErrorCode.tokenExpired.rawValue,
            ErrorCode.unauthorized.rawValue
        ].contains(code)
    }
    
    /// Check if error requires re-login
    var requiresReLogin: Bool {
        guard let code = code else { return false }
        return [
            ErrorCode.invalidToken.rawValue,
            ErrorCode.tokenExpired.rawValue,
            ErrorCode.unauthorized.rawValue
        ].contains(code)
    }
}

// MARK: - Mock Data

extension ErrorResponse {
    
    /// Mock validation error
    static var mockValidationError: ErrorResponse {
        return ErrorResponse(
            success: false,
            message: "Validation failed",
            errors: [
                FieldError(field: "email", message: "Invalid email format"),
                FieldError(field: "password", message: "Password must be at least 8 characters")
            ],
            code: ErrorCode.validationError.rawValue
        )
    }
    
    /// Mock authentication error
    static var mockAuthError: ErrorResponse {
        return ErrorResponse(
            success: false,
            message: "Invalid credentials",
            errors: nil,
            code: ErrorCode.invalidCredentials.rawValue
        )
    }
    
    /// Mock server error
    static var mockServerError: ErrorResponse {
        return ErrorResponse(
            success: false,
            message: "Internal server error",
            errors: nil,
            code: ErrorCode.serverError.rawValue
        )
    }
    
    /// Mock network error
    static var mockNetworkError: ErrorResponse {
        return ErrorResponse(
            success: false,
            message: "Network connection failed",
            errors: nil,
            code: ErrorCode.networkError.rawValue
        )
    }
}
