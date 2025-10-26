//
//  AuthenticationManager.swift
//  MacroLens
//
//  Path: MacroLens/Core/Auth/AuthenticationManager.swift
//
//  DEPENDENCIES:
//  - AuthService.swift
//  - User.swift
//  - Token models
//  - Keychain
//  - Combine
//
//  USED BY:
//  - MacroLensApp (root-level state)
//  - AuthViewModel
//  - All ViewModels needing auth state
//
//  PURPOSE:
//  - Single source of truth for authentication state
//  - Automatic token refresh
//  - Observable auth state via Combine
//  - Session management
//

import Foundation
import Combine
import KeychainAccess
import UIKit

/// Centralized authentication state manager
@MainActor
final class AuthenticationManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = AuthenticationManager()
    
    // MARK: - Published Properties
    
    /// Current authentication state
    @Published private(set) var isAuthenticated: Bool = false
    
    /// Current user (nil if not authenticated)
    @Published private(set) var currentUser: User?
    
    /// Loading state during auth operations
    @Published private(set) var isLoading: Bool = false
    
    /// Current error message
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let authService = AuthService.shared
    private let keychain = Keychain(service: Config.App.bundleIdentifier)
    private var cancellables = Set<AnyCancellable>()
    private var tokenRefreshTimer: Timer?
    
    // Token refresh interval (5 minutes before expiry)
    private let tokenRefreshInterval: TimeInterval = 55 * 60 // 55 minutes
    
    // MARK: - Initialization
    
    private init() {
        checkAuthenticationStatus()
        setupTokenRefreshTimer()
    }
    
    // MARK: - Authentication Status
    
    /// Check if user is authenticated and load user data
    func checkAuthenticationStatus() {
        isLoading = true
        
        // Check if tokens exist in Keychain
        guard authService.isAuthenticated else {
            isAuthenticated = false
            currentUser = nil
            isLoading = false
            Config.Logging.log("No valid tokens found", level: .debug)
            return
        }
        
        // Load current user
        Task {
            await loadCurrentUser()
        }
    }
    
    /// Async version - Check if user is authenticated and load user data
    func checkAuthenticationStatusAsync() async {
        await MainActor.run {
            isLoading = true
        }
        
        // Check if tokens exist in Keychain
        guard authService.isAuthenticated else {
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
                isLoading = false
            }
            Config.Logging.log("No valid tokens found", level: .debug)
            return
        }
        
        // Load current user
        await loadCurrentUser()
    }
    
    /// Load current user profile from API
    private func loadCurrentUser() async {
        do {
            let user = try await authService.getCurrentUser()
            
            // Update state
            self.currentUser = user
            self.isAuthenticated = true
            
            // Set user ID for analytics
            AnalyticsManager.shared.setUserId(user.id)
            CrashlyticsManager.shared.setUserId(user.id)
            
            Config.Logging.log("User authenticated: \(user.email)", level: .info)
            
        } catch {
            Config.Logging.log("Failed to load user: \(error)", level: .error)
            
            // If token is invalid, clear session
            if case APIError.unauthorized = error {
                await clearSession()
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Login
    
    /// Login with email and password
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    /// - Throws: Authentication error
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, tokens) = try await authService.login(
                email: email,
                password: password
            )
            
            // Update state
            self.currentUser = user
            self.isAuthenticated = true
            
            // Track login
            AnalyticsManager.shared.trackLogin(method: "email")
            AnalyticsManager.shared.setUserId(user.id)
            CrashlyticsManager.shared.setUserId(user.id)
            
            // Start token refresh
            startTokenRefreshTimer()
            
            Config.Logging.log("Login successful: \(user.email)", level: .info)
            
        } catch {
            errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            Config.Logging.log("Login failed: \(error)", level: .error)
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Register
    
    /// Register new user
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    ///   - fullName: User full name
    /// - Throws: Registration error
    func register(email: String, password: String, fullName: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, tokens) = try await authService.register(
                email: email,
                password: password,
                fullName: fullName
            )
            
            // Update state
            self.currentUser = user
            self.isAuthenticated = true
            
            // Track registration
            AnalyticsManager.shared.trackRegistration(method: "email")
            AnalyticsManager.shared.setUserId(user.id)
            CrashlyticsManager.shared.setUserId(user.id)
            
            // Start token refresh
            startTokenRefreshTimer()
            
            Config.Logging.log("Registration successful: \(user.email)", level: .info)
            
        } catch {
            errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            Config.Logging.log("Registration failed: \(error)", level: .error)
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Social Login
    
    /// Login with Google
    /// - Parameter presentingViewController: View controller to present Google Sign-In
    func loginWithGoogle(presentingViewController: UIViewController) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, tokens) = try await SocialAuthService.shared.signInWithGoogle(
                presentingViewController: presentingViewController
            )
            
            // Update state
            self.currentUser = user
            self.isAuthenticated = true
            
            // Track login
            AnalyticsManager.shared.trackLogin(method: "google")
            AnalyticsManager.shared.setUserId(user.id)
            CrashlyticsManager.shared.setUserId(user.id)
            
            // Start token refresh
            startTokenRefreshTimer()
            
            Config.Logging.log("Google login successful: \(user.email)", level: .info)
            
        } catch {
            errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            Config.Logging.log("Google login failed: \(error)", level: .error)
            throw error
        }
        
        isLoading = false
    }
    
    /// Login with Apple
    func loginWithApple() async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let (user, tokens) = try await SocialAuthService.shared.signInWithApple()
            
            // Update state
            self.currentUser = user
            self.isAuthenticated = true
            
            // Track login
            AnalyticsManager.shared.trackLogin(method: "apple")
            AnalyticsManager.shared.setUserId(user.id)
            CrashlyticsManager.shared.setUserId(user.id)
            
            // Start token refresh
            startTokenRefreshTimer()
            
            Config.Logging.log("Apple login successful: \(user.email)", level: .info)
            
        } catch {
            errorMessage = NetworkManager.shared.friendlyErrorMessage(error)
            Config.Logging.log("Apple login failed: \(error)", level: .error)
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    
    /// Logout current user and clear session
    func logout() {
        Task {
            await clearSession()
            
            // Track logout
            AnalyticsManager.shared.trackLogout()
            
            Config.Logging.log("User logged out", level: .info)
        }
    }
    
    /// Clear all session data
    private func clearSession() async {
        // Stop token refresh
        stopTokenRefreshTimer()
        
        // Clear auth service tokens
        authService.clearAuthData()
        
        // Clear state
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
        
        // Clear analytics
        AnalyticsManager.shared.clearUserId()
        CrashlyticsManager.shared.clearUserId()
        
        Config.Logging.log("Session cleared", level: .debug)
    }
    
    // MARK: - Token Refresh
    
    /// Setup automatic token refresh timer
    private func setupTokenRefreshTimer() {
        // Only start if authenticated
        guard isAuthenticated else { return }
        startTokenRefreshTimer()
    }
    
    /// Start token refresh timer
    private func startTokenRefreshTimer() {
        stopTokenRefreshTimer()
        
        tokenRefreshTimer = Timer.scheduledTimer(
            withTimeInterval: tokenRefreshInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshTokenIfNeeded()
            }
        }
        
        Config.Logging.log("Token refresh timer started", level: .debug)
    }
    
    /// Stop token refresh timer
    private func stopTokenRefreshTimer() {
        tokenRefreshTimer?.invalidate()
        tokenRefreshTimer = nil
        Config.Logging.log("Token refresh timer stopped", level: .debug)
    }
    
    /// Refresh access token if needed
    private func refreshTokenIfNeeded() async {
        guard isAuthenticated else { return }
        
        do {
            let tokens = try await authService.refreshToken()
            Config.Logging.log("Token refreshed successfully", level: .debug)
            
            // Track successful refresh
            CrashlyticsManager.shared.log("Token refresh successful")
            
        } catch {
            Config.Logging.log("Token refresh failed: \(error)", level: .error)
            
            // If refresh fails with unauthorized, clear session
            if case APIError.unauthorized = error {
                await clearSession()
                errorMessage = "Your session has expired. Please sign in again."
            }
            
            // Track refresh failure
            CrashlyticsManager.shared.recordAuthError(
                errorType: "token_refresh",
                message: error.localizedDescription
            )
        }
    }
    
    // MARK: - User Update
    
    /// Update current user (after profile changes)
    /// - Parameter user: Updated user object
    func updateCurrentUser(_ user: User) {
        self.currentUser = user
        Config.Logging.log("Current user updated", level: .debug)
    }
    
    /// Reload current user from API
    func reloadCurrentUser() async {
        guard isAuthenticated else { return }
        await loadCurrentUser()
    }
    
    // MARK: - Helpers
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Usage Examples

/*
 
 // MARK: - In MacroLensApp
 
 @main
 struct MacroLensApp: App {
     @StateObject private var authManager = AuthenticationManager.shared
     
     var body: some Scene {
         WindowGroup {
             if authManager.isAuthenticated {
                 MainTabView()
             } else {
                 LoginView()
             }
         }
         .environmentObject(authManager)
     }
 }
 
 
 // MARK: - In ViewModels
 
 class DashboardViewModel: ObservableObject {
     private let authManager = AuthenticationManager.shared
     private var cancellables = Set<AnyCancellable>()
     
     init() {
         // Observe auth state
         authManager.$isAuthenticated
             .sink { [weak self] isAuthenticated in
                 if !isAuthenticated {
                     // Handle logout
                 }
             }
             .store(in: &cancellables)
     }
 }
 
 
 // MARK: - Login Action
 
 Button("Sign In") {
     Task {
         do {
             try await AuthenticationManager.shared.login(
                 email: email,
                 password: password
             )
         } catch {
             // Error handled by AuthenticationManager
         }
     }
 }
 
 
 // MARK: - Logout Action
 
 Button("Logout") {
     AuthenticationManager.shared.logout()
 }
 
 */
