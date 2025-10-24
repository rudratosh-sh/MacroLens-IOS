//
//  BiometricAuthManager.swift
//  MacroLens
//
//  Path: MacroLens/Services/BiometricAuthManager.swift
//
//  Description: Manages biometric authentication (Face ID/Touch ID) with secure credential storage
//

import Foundation
import LocalAuthentication
import KeychainAccess

/// Manager for biometric authentication operations
@MainActor
final class BiometricAuthManager: @unchecked Sendable {
    
    // MARK: - Singleton
    static let shared = BiometricAuthManager()
    
    // MARK: - Properties
    private let keychain = Keychain(service: Config.App.bundleIdentifier)
        .accessibility(.whenUnlockedThisDeviceOnly)
    
    private let biometricEnabledKey = "biometric_auth_enabled"
    private let storedEmailKey = "biometric_stored_email"
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Biometric Availability
    
    /// Check available biometric type
    /// - Returns: LABiometryType (faceID, touchID, or none)
    func biometricType() -> LABiometryType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                Config.Logging.log("Biometric unavailable: \(error.localizedDescription)", level: .warning)
            }
            return .none
        }
        
        return context.biometryType
    }
    
    /// Check if biometric authentication is available
    /// - Returns: Boolean indicating availability
    func isBiometricAvailable() -> Bool {
        return biometricType() != .none
    }
    
    /// Check if biometric is enabled for this user
    /// - Returns: Boolean indicating if biometric auth is enabled
    func isBiometricEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: biometricEnabledKey)
    }
    
    /// Get biometric display name
    /// - Returns: User-friendly name (Face ID/Touch ID/Biometrics)
    func biometricDisplayName() -> String {
        switch biometricType() {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometrics"
        }
    }
    
    // MARK: - Credential Storage
    
    /// Enable biometric authentication and store email
    /// - Parameters:
    ///   - email: User email to store securely
    /// - Throws: KeychainAccess.Status on failure
    func enableBiometric(email: String) throws {
        try keychain.set(email, key: storedEmailKey)
        UserDefaults.standard.set(true, forKey: biometricEnabledKey)
        Config.Logging.log("Biometric authentication enabled", level: .info)
    }
    
    /// Disable biometric authentication and clear stored credentials
    func disableBiometric() {
        try? keychain.remove(storedEmailKey)
        UserDefaults.standard.set(false, forKey: biometricEnabledKey)
        Config.Logging.log("Biometric authentication disabled", level: .info)
    }
    
    /// Get stored email if biometric is enabled
    /// - Returns: Stored email or nil
    func getStoredEmail() -> String? {
        guard isBiometricEnabled() else {
            return nil
        }
        return try? keychain.get(storedEmailKey)
    }
    
    // MARK: - Authentication
    
    /// Authenticate user with biometrics
    /// - Returns: Stored email on success, nil on failure
    /// - Throws: BiometricError on authentication failure
    func authenticateWithBiometrics() async throws -> String {
        guard isBiometricAvailable() else {
            throw BiometricError.notAvailable
        }
        
        guard isBiometricEnabled(), let storedEmail = getStoredEmail() else {
            throw BiometricError.notEnrolled
        }
        
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"
        
        let reason = "Login to MacroLens with \(biometricDisplayName())"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if success {
                Config.Logging.log("Biometric authentication successful", level: .info)
                return storedEmail
            } else {
                throw BiometricError.authenticationFailed
            }
        } catch let error as LAError {
            Config.Logging.log("Biometric auth failed: \(error.localizedDescription)", level: .error)
            throw BiometricError.from(laError: error)
        } catch {
            throw BiometricError.authenticationFailed
        }
    }
    
    // MARK: - Prompt for Enrollment
    
    /// Check if we should prompt user to enable biometric
    /// - Returns: Boolean indicating if prompt should be shown
    func shouldPromptForEnrollment() -> Bool {
        let hasPrompted = UserDefaults.standard.bool(forKey: "has_prompted_biometric")
        return isBiometricAvailable() && !isBiometricEnabled() && !hasPrompted
    }
    
    /// Mark that we've prompted the user
    func markPromptShown() {
        UserDefaults.standard.set(true, forKey: "has_prompted_biometric")
    }
}

// MARK: - Biometric Error Types

enum BiometricError: LocalizedError {
    case notAvailable
    case notEnrolled
    case authenticationFailed
    case userCancel
    case userFallback
    case systemCancel
    case passcodeNotSet
    case biometryNotEnrolled
    case biometryLockout
    case unknown
    
    // Helper that does not rely on BiometricAuthManager (avoids main-actor isolation).
    private static func currentBiometricDisplayName() -> String {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            default: return "Biometrics"
            }
        } else {
            return "Biometrics"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device"
        case .notEnrolled:
            return "Biometric authentication is not set up. Please enable it in settings"
        case .authenticationFailed:
            return "Biometric authentication failed. Please try again"
        case .userCancel:
            return "Authentication cancelled"
        case .userFallback:
            return "User chose to enter password"
        case .systemCancel:
            return "Authentication was cancelled by the system"
        case .passcodeNotSet:
            return "Passcode is not set on this device"
        case .biometryNotEnrolled:
            return "\(Self.currentBiometricDisplayName()) is not enrolled"
        case .biometryLockout:
            return "\(Self.currentBiometricDisplayName()) is locked. Please try again later"
        case .unknown:
            return "An unknown error occurred"
        }
    }
    
    /// Convert LAError to BiometricError
    static func from(laError: LAError) -> BiometricError {
        switch laError.code {
            case .authenticationFailed:
                return .authenticationFailed
            case .userCancel:
                return .userCancel
            case .userFallback:
                return .userFallback
            case .systemCancel:
                return .systemCancel
            case .passcodeNotSet:
                return .passcodeNotSet
            case .biometryNotEnrolled:
                return .biometryNotEnrolled
            case .biometryLockout:
                return .biometryLockout
            default:
                return .unknown
        }
    }
}
