//
//  FeatureFlags.swift
//  MacroLens
//
//  Created for: Day 1 - Task 1.4 (Core Architecture Setup)
//  Path: MacroLens/Core/FeatureFlags.swift
//
//  PURPOSE:
//  Centralized feature flag management with runtime control and remote configuration support.
//  Separates feature toggles from Config.swift for better maintainability and A/B testing capability.
//
//  DEPENDENCIES:
//  - Config.swift (reads default values from Config.Features)
//  - UserDefaults (stores remote config cache)
//  - Combine (for @Published reactive properties)
//
//  USED BY:
//  - Views (to conditionally show/hide features)
//  - ViewModels (to check feature availability)
//  - AppDelegate/SceneDelegate (to fetch remote config on launch)
//  - Settings screens (to display available features)
//
//  INTEGRATION:
//  Call FeatureFlags.shared.isEnabled(.featureName) to check if a feature is enabled
//  Call FeatureFlags.shared.fetchRemoteConfig() on app launch (Day 20 - Firebase integration)
//

import Foundation
import Combine

/// Feature flag manager supporting local and remote configuration
/// Thread-safe singleton for managing feature availability across the app
@MainActor
final class FeatureFlags: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = FeatureFlags()
    
    // MARK: - Published Properties (for SwiftUI observation)
    
    @Published private(set) var isHealthKitEnabled: Bool
    @Published private(set) var isBarcodeScanningEnabled: Bool
    @Published private(set) var isAIMealPlanningEnabled: Bool
    @Published private(set) var isRecipesEnabled: Bool
    @Published private(set) var isSocialSharingEnabled: Bool
    @Published private(set) var isPremiumFeaturesEnabled: Bool
    
    // MARK: - Remote Config Properties
    
    /// Indicates if remote config has been fetched
    @Published private(set) var isRemoteConfigLoaded: Bool = false
    
    /// Last time remote config was fetched
    private(set) var lastFetchTime: Date?
    
    // MARK: - Storage
    
    private let userDefaults = UserDefaults.standard
    private let remoteConfigKey = "feature_flags_remote"
    private let lastFetchKey = "feature_flags_last_fetch"
    
    // MARK: - Initialization
    
    private init() {
        // Load default values from Config
        self.isHealthKitEnabled = Config.Features.enableHealthKit
        self.isBarcodeScanningEnabled = Config.Features.enableBarcodeScanning
        self.isAIMealPlanningEnabled = Config.Features.enableAIMealPlanning
        self.isRecipesEnabled = Config.Features.enableRecipes
        self.isSocialSharingEnabled = Config.Features.enableSocialSharing
        self.isPremiumFeaturesEnabled = Config.Features.enablePremiumFeatures
        
        // Load remote overrides if available
        loadRemoteOverrides()
        
        // Apply development overrides if in debug mode
        applyDevelopmentOverrides()
        
        Config.Logging.log("FeatureFlags initialized", level: .info)
    }
    
    // MARK: - Public API
    
    /// Check if a specific feature is enabled
    /// - Parameter feature: The feature to check
    /// - Returns: Boolean indicating if feature is enabled
    func isEnabled(_ feature: Feature) -> Bool {
        switch feature {
        case .healthKit:
            return isHealthKitEnabled
        case .barcodeScanning:
            return isBarcodeScanningEnabled
        case .aiMealPlanning:
            return isAIMealPlanningEnabled
        case .recipes:
            return isRecipesEnabled
        case .socialSharing:
            return isSocialSharingEnabled
        case .premiumFeatures:
            return isPremiumFeaturesEnabled
        }
    }
    
    /// Fetch feature flags from remote config (Firebase Remote Config)
    /// Call this on app launch after authentication
    func fetchRemoteConfig() async {
        // TODO: Implement Firebase Remote Config integration in Day 20
        // For now, we'll simulate a remote fetch
        
        Config.Logging.log("Fetching remote feature flags...", level: .info)
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // In production, this would fetch from Firebase Remote Config
        // Example structure:
        // {
        //   "enable_healthkit": true,
        //   "enable_barcode_scanning": true,
        //   "enable_social_sharing": false,
        //   "enable_premium_features": false
        // }
        
        lastFetchTime = Date()
        userDefaults.set(lastFetchTime, forKey: lastFetchKey)
        isRemoteConfigLoaded = true
        
        Config.Logging.log("Remote feature flags fetched successfully", level: .info)
    }
    
    /// Reset all feature flags to default values
    func resetToDefaults() {
        isHealthKitEnabled = Config.Features.enableHealthKit
        isBarcodeScanningEnabled = Config.Features.enableBarcodeScanning
        isAIMealPlanningEnabled = Config.Features.enableAIMealPlanning
        isRecipesEnabled = Config.Features.enableRecipes
        isSocialSharingEnabled = Config.Features.enableSocialSharing
        isPremiumFeaturesEnabled = Config.Features.enablePremiumFeatures
        
        // Clear remote config cache
        userDefaults.removeObject(forKey: remoteConfigKey)
        userDefaults.removeObject(forKey: lastFetchKey)
        
        Config.Logging.log("Feature flags reset to defaults", level: .info)
    }
    
    // MARK: - Development Overrides
    
    /// Enable a feature temporarily for development/testing
    /// Only works in DEBUG builds
    /// - Parameters:
    ///   - feature: The feature to enable
    ///   - enabled: Whether to enable or disable
    func setOverride(for feature: Feature, enabled: Bool) {
        #if DEBUG
        switch feature {
        case .healthKit:
            isHealthKitEnabled = enabled
        case .barcodeScanning:
            isBarcodeScanningEnabled = enabled
        case .aiMealPlanning:
            isAIMealPlanningEnabled = enabled
        case .recipes:
            isRecipesEnabled = enabled
        case .socialSharing:
            isSocialSharingEnabled = enabled
        case .premiumFeatures:
            isPremiumFeaturesEnabled = enabled
        }
        
        Config.Logging.log("Development override: \(feature.rawValue) = \(enabled)", level: .debug)
        #else
        Config.Logging.log("Feature overrides only available in DEBUG builds", level: .warning)
        #endif
    }
    
    // MARK: - Private Methods
    
    /// Load feature flags from remote config cache
    private func loadRemoteOverrides() {
        guard let savedConfig = userDefaults.dictionary(forKey: remoteConfigKey) else {
            return
        }
        
        // Apply remote overrides
        if let healthKit = savedConfig["enable_healthkit"] as? Bool {
            isHealthKitEnabled = healthKit
        }
        if let barcodeScanning = savedConfig["enable_barcode_scanning"] as? Bool {
            isBarcodeScanningEnabled = barcodeScanning
        }
        if let aiMealPlanning = savedConfig["enable_ai_meal_planning"] as? Bool {
            isAIMealPlanningEnabled = aiMealPlanning
        }
        if let recipes = savedConfig["enable_recipes"] as? Bool {
            isRecipesEnabled = recipes
        }
        if let socialSharing = savedConfig["enable_social_sharing"] as? Bool {
            isSocialSharingEnabled = socialSharing
        }
        if let premiumFeatures = savedConfig["enable_premium_features"] as? Bool {
            isPremiumFeaturesEnabled = premiumFeatures
        }
        
        // Load last fetch time
        lastFetchTime = userDefaults.object(forKey: lastFetchKey) as? Date
        isRemoteConfigLoaded = true
        
        Config.Logging.log("Loaded remote feature flag overrides", level: .info)
    }
    
    /// Apply development-specific overrides for testing
    private func applyDevelopmentOverrides() {
        #if DEBUG
        // In development, you might want to enable features under development
        // Uncomment features you're actively working on:
        
        // isBarcodeScanningEnabled = true
        // isSocialSharingEnabled = true // Test Phase 2 features
        // isPremiumFeaturesEnabled = true // Test premium flow
        
        Config.Logging.log("Development overrides applied", level: .debug)
        #endif
    }
    
    /// Save current configuration to remote config cache
    private func saveRemoteConfig(_ config: [String: Any]) {
        userDefaults.set(config, forKey: remoteConfigKey)
        userDefaults.set(Date(), forKey: lastFetchKey)
    }
}

// MARK: - Feature Enum

extension FeatureFlags {
    /// All available features in the app
    enum Feature: String, CaseIterable {
        case healthKit = "healthkit"
        case barcodeScanning = "barcode_scanning"
        case aiMealPlanning = "ai_meal_planning"
        case recipes = "recipes"
        case socialSharing = "social_sharing"
        case premiumFeatures = "premium_features"
        
        /// User-friendly name for the feature
        var displayName: String {
            switch self {
            case .healthKit:
                return "Apple Health Integration"
            case .barcodeScanning:
                return "Barcode Scanning"
            case .aiMealPlanning:
                return "AI Meal Planning"
            case .recipes:
                return "Recipe Discovery"
            case .socialSharing:
                return "Social Sharing"
            case .premiumFeatures:
                return "Premium Features"
            }
        }
        
        /// Description of what the feature does
        var description: String {
            switch self {
            case .healthKit:
                return "Sync nutrition data with Apple Health app"
            case .barcodeScanning:
                return "Scan product barcodes to quickly log food"
            case .aiMealPlanning:
                return "Get personalized meal plans powered by AI"
            case .recipes:
                return "Discover and save macro-friendly recipes"
            case .socialSharing:
                return "Share progress with friends and community"
            case .premiumFeatures:
                return "Access premium analysis and coaching features"
            }
        }
    }
}

// MARK: - SwiftUI Convenience

extension FeatureFlags {
    /// Check if feature should be shown in UI
    /// - Parameter feature: The feature to check
    /// - Returns: Boolean indicating if feature UI should be visible
    func shouldShow(_ feature: Feature) -> Bool {
        isEnabled(feature)
    }
}
