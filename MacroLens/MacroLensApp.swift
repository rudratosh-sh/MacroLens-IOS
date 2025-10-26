//
//  MacroLensApp.swift
//  MacroLens
//
//  DEPENDENCIES:
//  - FirebaseCore
//  - FirebaseAnalytics
//  - FirebaseCrashlytics
//  - AuthViewModel
//  - MainTabView
//  - LoginView
//
//  PURPOSE:
//  - Main app entry point
//  - Firebase initialization
//  - Root navigation logic (authenticated vs unauthenticated)
//
//  Created by Rudra on 15/10/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics

@main
struct MacroLensApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    // MARK: - Initialization
    
    init() {
        // Configure Firebase
        configureFirebase()
        
        // Configure app appearance
        configureAppearance()
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                        .environmentObject(authViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                // Track app launch
                Analytics.logEvent("app_launch", parameters: [
                    "environment": Config.environment.description,
                    "version": Config.App.version,
                    "build": Config.App.build
                ])
            }
        }
    }
    
    // MARK: - Configuration
    
    /// Configure Firebase services
    private func configureFirebase() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        Config.Logging.log("Firebase configured successfully", level: .info)
        
        // Configure Analytics
        configureAnalytics()
        
        // Configure Crashlytics
        configureCrashlytics()
    }
    
    /// Configure Firebase Analytics
    private func configureAnalytics() {
        // Enable analytics collection
        Analytics.setAnalyticsCollectionEnabled(true)
        
        // Set user properties
        Analytics.setUserProperty(Config.App.version, forName: "app_version")
        Analytics.setUserProperty(Config.environment.description, forName: "environment")
        
        Config.Logging.log("Firebase Analytics configured", level: .info)
    }
    
    /// Configure Firebase Crashlytics
    private func configureCrashlytics() {
        // Enable automatic crash collection
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        // Set custom keys for better crash context
        Crashlytics.crashlytics().setCustomValue(Config.App.version, forKey: "app_version")
        Crashlytics.crashlytics().setCustomValue(Config.App.build, forKey: "build_number")
        Crashlytics.crashlytics().setCustomValue(Config.environment.description, forKey: "environment")
        
        Config.Logging.log("Firebase Crashlytics configured", level: .info)
    }
    
    /// Configure app-wide appearance
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.backgroundPrimary)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.textPrimary)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.textPrimary)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.backgroundPrimary)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        Config.Logging.log("App appearance configured", level: .info)
    }
}

// MARK: - Environment Description Extension

extension AppEnvironment: CustomStringConvertible {
    var description: String {
        switch self {
        case .development:
            return "development"
        case .staging:
            return "staging"
        case .production:
            return "production"
        }
    }
}
