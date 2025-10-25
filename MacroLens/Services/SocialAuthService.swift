//
//  SocialAuthService.swift
//  MacroLens
//
//  Path: MacroLens/Services/SocialAuthService.swift
//
//  Description: Service for handling social authentication (Google, Apple)
//

import Foundation
import GoogleSignIn
import AuthenticationServices
import KeychainAccess
import SwiftUI
import MacroLens

/// Service for social authentication operations
final class SocialAuthService: NSObject, @unchecked Sendable {
    
    // MARK: - Singleton
    static let shared = SocialAuthService()
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private let keychain = Keychain(service: Config.App.bundleIdentifier)
    
    // Continuation for Apple Sign In (since it uses delegate pattern)
    private var appleSignInContinuation: CheckedContinuation<(User, Token), Error>?
    
    // MARK: - Initialization
    private override init() {
        super.init()
    }
    
    // MARK: - Google Sign In
    
    /// Sign in with Google
    /// - Parameter presentingViewController: The view controller to present Google Sign In
    /// - Returns: User and tokens from successful authentication
    /// - Throws: SocialAuthError on failure
    func signInWithGoogle(presentingViewController: UIViewController) async throws -> (User, Token) {
        // Configure Google Sign In
        let clientID = Config.OAuth.googleClientID
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Perform sign in
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController
            )
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw SocialAuthError.noIdentityToken
            }
            
            let email = result.user.profile?.email ?? ""
            let fullName = result.user.profile?.name
            
            // Call backend
            let parameters: [String: Any] = [
                "provider": "google",
                "id_token": idToken,
                "email": email,
                "full_name": fullName as Any
            ]
            
            let response: AuthResponse = try await networkManager.post(
                endpoint: "/auth/social",
                parameters: parameters
            )
            
            // Save tokens
            try saveTokens(
                accessToken: response.tokens.accessToken,
                refreshToken: response.tokens.refreshToken,
                userId: response.user.id,
                userEmail: response.user.email
            )
            
            Config.Logging.log("Google Sign In successful: \(response.user.email)", level: .info)
            
            return (response.user, response.tokens)
            
        } catch let error as GIDSignInError {
            if error.code == .canceled {
                throw SocialAuthError.cancelled
            }
            throw SocialAuthError.unknown(error)
        } catch {
            throw error
        }
    }
    
    /// Sign out from Google
    func signOutGoogle() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    // MARK: - Apple Sign In
    
    /// Sign in with Apple
    /// - Returns: User and tokens from successful authentication
    /// - Throws: SocialAuthError on failure
    @MainActor
    func signInWithApple() async throws -> (User, Token) {
        return try await withCheckedThrowingContinuation { continuation in
            self.appleSignInContinuation = continuation
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    // MARK: - Token Management
    
    /// Save authentication tokens to keychain
    private func saveTokens(
        accessToken: String,
        refreshToken: String,
        userId: String,
        userEmail: String
    ) throws {
        try keychain.set(accessToken, key: Config.StorageKeys.accessToken)
        try keychain.set(refreshToken, key: Config.StorageKeys.refreshToken)
        try keychain.set(userId, key: Config.StorageKeys.userId)
        try keychain.set(userEmail, key: Config.StorageKeys.userEmail)
        
        // Update APIClient tokens
        APIClient.shared.accessToken = accessToken
        APIClient.shared.refreshToken = refreshToken
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension SocialAuthService: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task {
            do {
                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    appleSignInContinuation?.resume(throwing: SocialAuthError.invalidCredential)
                    return
                }
                
                guard let identityTokenData = credential.identityToken,
                      let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                    appleSignInContinuation?.resume(throwing: SocialAuthError.noIdentityToken)
                    return
                }
                
                // Extract user info
                var fullName: String?
                if let nameComponents = credential.fullName {
                    let parts = [nameComponents.givenName, nameComponents.familyName]
                        .compactMap { $0 }
                    if !parts.isEmpty {
                        fullName = parts.joined(separator: " ")
                    }
                }
                
                // Call backend
                let parameters: [String: Any] = [
                    "provider": "apple",
                    "id_token": identityToken,
                    "email": credential.email as Any,
                    "full_name": fullName as Any
                ]
                
                let response: AuthResponse = try await networkManager.post(
                    endpoint: "/auth/social",
                    parameters: parameters
                )
                
                // Save tokens
                try saveTokens(
                    accessToken: response.tokens.accessToken,
                    refreshToken: response.tokens.refreshToken,
                    userId: response.user.id,
                    userEmail: response.user.email
                )
                
                // Store Apple user ID for future sign-ins
                try? keychain.set(credential.user, key: Config.StorageKeys.appleUserIdentifier)
                
                Config.Logging.log("Apple Sign In successful: \(response.user.email)", level: .info)
                
                appleSignInContinuation?.resume(returning: (response.user, response.tokens))
                
            } catch {
                appleSignInContinuation?.resume(throwing: error)
            }
        }
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let authError = error as? ASAuthorizationError
        if authError?.code == .canceled {
            appleSignInContinuation?.resume(throwing: SocialAuthError.cancelled)
        } else {
            appleSignInContinuation?.resume(throwing: SocialAuthError.unknown(error))
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension SocialAuthService: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}
