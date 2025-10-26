//
//  UserDefaultsManager.swift
//  MacroLens
//
//  Created for: Day 1 - Task 1.4 (Core Architecture Setup)
//  Path: MacroLens/Core/Storage/UserDefaultsManager.swift
//
//  PURPOSE:
//  Type-safe wrapper for UserDefaults with structured preference management.
//  Centralizes all app preferences and settings in one place.
//  Provides default values and prevents key typos.
//
//  DEPENDENCIES:
//  - Foundation (UserDefaults)
//  - Config.swift (storage keys)
//
//  USED BY:
//  - Views (to read/write user preferences)
//  - ViewModels (to manage settings)
//  - Services (to check app state flags)
//  - AuthService (for onboarding/biometric flags)
//
//  BENEFITS:
//  - Type-safe access to preferences
//  - Single source of truth for defaults
//  - Easy to test and mock
//  - Prevents key string typos
//

import Foundation
import Combine

// MARK: - User Defaults Manager

/// Manager for handling user preferences and app state using UserDefaults
@MainActor
final class UserDefaultsManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = UserDefaultsManager()
    
    // MARK: - Properties
    
    private let defaults: UserDefaults
    private let suiteName: String?
    
    // MARK: - Published Properties (for SwiftUI observation)
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            defaults.set(hasCompletedOnboarding, forKey: Keys.onboardingCompleted)
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }
    
    @Published var selectedTheme: Theme {
        didSet {
            defaults.set(selectedTheme.rawValue, forKey: Keys.selectedTheme)
        }
    }
    
    @Published var selectedMeasurementUnit: MeasurementUnit {
        didSet {
            defaults.set(selectedMeasurementUnit.rawValue, forKey: Keys.measurementUnit)
        }
    }
    
    // MARK: - Initialization
    
    private init(suiteName: String? = nil) {
        self.suiteName = suiteName
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        
        // Load initial values
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.onboardingCompleted)
        self.notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)
        
        let themeRawValue = defaults.string(forKey: Keys.selectedTheme) ?? Theme.system.rawValue
        self.selectedTheme = Theme(rawValue: themeRawValue) ?? .system
        
        let unitRawValue = defaults.string(forKey: Keys.measurementUnit) ?? MeasurementUnit.metric.rawValue
        self.selectedMeasurementUnit = MeasurementUnit(rawValue: unitRawValue) ?? .metric
        
        Config.Logging.log("UserDefaultsManager initialized", level: .info)
    }
    
    // MARK: - Storage Keys
    
    private struct Keys {
        // Onboarding & First Launch
        static let onboardingCompleted = Config.StorageKeys.onboardingCompleted
        static let hasPromptedBiometric = "has_prompted_biometric"
        static let firstLaunchDate = "first_launch_date"
        static let appLaunchCount = "app_launch_count"
        
        // Authentication State
        static let lastLoginDate = "last_login_date"
        static let lastSyncDate = "last_sync_date"
        
        // Notifications
        static let notificationsEnabled = Config.StorageKeys.notificationsEnabled
        static let mealRemindersEnabled = "meal_reminders_enabled"
        static let waterRemindersEnabled = "water_reminders_enabled"
        static let goalAchievementNotifications = "goal_achievement_notifications"
        
        // App Preferences
        static let selectedTheme = "selected_theme"
        static let measurementUnit = "measurement_unit"
        static let weekStartDay = "week_start_day"
        
        // Health Integration
        static let healthKitAuthorized = Config.StorageKeys.healthKitAuthorized
        static let healthKitSyncEnabled = "healthkit_sync_enabled"
        static let lastHealthKitSync = "last_healthkit_sync"
        
        // Data & Privacy
        static let analyticsEnabled = "analytics_enabled"
        static let crashReportingEnabled = "crash_reporting_enabled"
        
        // Feature Flags (Local Overrides)
        static let localFeatureFlags = "local_feature_flags"
        
        // Cache Settings
        static let imageCacheSize = "image_cache_size"
        static let lastCacheClearDate = "last_cache_clear_date"
    }
    
    // MARK: - Onboarding & First Launch
    
    /// Mark onboarding as completed
    func completeOnboarding() {
        hasCompletedOnboarding = true
        Config.Logging.log("Onboarding completed", level: .info)
    }
    
    /// Check if this is first app launch
    var isFirstLaunch: Bool {
        let hasLaunched = defaults.bool(forKey: "has_launched_before")
        if !hasLaunched {
            defaults.set(true, forKey: "has_launched_before")
            recordFirstLaunch()
        }
        return !hasLaunched
    }
    
    /// Record first launch date
    private func recordFirstLaunch() {
        defaults.set(Date(), forKey: Keys.firstLaunchDate)
        defaults.set(1, forKey: Keys.appLaunchCount)
    }
    
    /// Increment app launch count
    func incrementLaunchCount() {
        let count = appLaunchCount
        defaults.set(count + 1, forKey: Keys.appLaunchCount)
    }
    
    /// Get app launch count
    var appLaunchCount: Int {
        return defaults.integer(forKey: Keys.appLaunchCount)
    }
    
    /// Get first launch date
    var firstLaunchDate: Date? {
        return defaults.object(forKey: Keys.firstLaunchDate) as? Date
    }
    
    // MARK: - Biometric Prompt
    
    /// Check if we should prompt for biometric enrollment
    var shouldPromptBiometric: Bool {
        return !defaults.bool(forKey: Keys.hasPromptedBiometric)
    }
    
    /// Mark biometric prompt as shown
    func markBiometricPromptShown() {
        defaults.set(true, forKey: Keys.hasPromptedBiometric)
    }
    
    /// Reset biometric prompt (for testing)
    func resetBiometricPrompt() {
        defaults.set(false, forKey: Keys.hasPromptedBiometric)
    }
    
    // MARK: - Authentication State
    
    /// Record last login date
    func recordLogin() {
        defaults.set(Date(), forKey: Keys.lastLoginDate)
    }
    
    /// Get last login date
    var lastLoginDate: Date? {
        return defaults.object(forKey: Keys.lastLoginDate) as? Date
    }
    
    /// Record last sync date
    func recordSync() {
        defaults.set(Date(), forKey: Keys.lastSyncDate)
    }
    
    /// Get last sync date
    var lastSyncDate: Date? {
        return defaults.object(forKey: Keys.lastSyncDate) as? Date
    }
    
    // MARK: - Notification Preferences
    
    /// Enable/disable meal reminders
    func setMealReminders(enabled: Bool) {
        defaults.set(enabled, forKey: Keys.mealRemindersEnabled)
    }
    
    /// Check if meal reminders are enabled
    var mealRemindersEnabled: Bool {
        get { defaults.bool(forKey: Keys.mealRemindersEnabled) }
        set { defaults.set(newValue, forKey: Keys.mealRemindersEnabled) }
    }
    
    /// Enable/disable water reminders
    func setWaterReminders(enabled: Bool) {
        defaults.set(enabled, forKey: Keys.waterRemindersEnabled)
    }
    
    /// Check if water reminders are enabled
    var waterRemindersEnabled: Bool {
        get { defaults.bool(forKey: Keys.waterRemindersEnabled) }
        set { defaults.set(newValue, forKey: Keys.waterRemindersEnabled) }
    }
    
    /// Enable/disable goal achievement notifications
    var goalNotificationsEnabled: Bool {
        get { defaults.bool(forKey: Keys.goalAchievementNotifications) }
        set { defaults.set(newValue, forKey: Keys.goalAchievementNotifications) }
    }
    
    // MARK: - Health Integration
    
    /// Mark HealthKit as authorized
    func setHealthKitAuthorized(_ authorized: Bool) {
        defaults.set(authorized, forKey: Keys.healthKitAuthorized)
    }
    
    /// Check if HealthKit is authorized
    var isHealthKitAuthorized: Bool {
        return defaults.bool(forKey: Keys.healthKitAuthorized)
    }
    
    /// Enable/disable HealthKit sync
    var healthKitSyncEnabled: Bool {
        get { defaults.bool(forKey: Keys.healthKitSyncEnabled) }
        set { defaults.set(newValue, forKey: Keys.healthKitSyncEnabled) }
    }
    
    /// Record last HealthKit sync
    func recordHealthKitSync() {
        defaults.set(Date(), forKey: Keys.lastHealthKitSync)
    }
    
    /// Get last HealthKit sync date
    var lastHealthKitSync: Date? {
        return defaults.object(forKey: Keys.lastHealthKitSync) as? Date
    }
    
    // MARK: - Week Start Day
    
    /// Set week start day (0 = Sunday, 1 = Monday)
    var weekStartDay: Int {
        get { defaults.integer(forKey: Keys.weekStartDay) }
        set { defaults.set(newValue, forKey: Keys.weekStartDay) }
    }
    
    // MARK: - Analytics & Privacy
    
    /// Enable/disable analytics tracking
    var analyticsEnabled: Bool {
        get { defaults.bool(forKey: Keys.analyticsEnabled) }
        set { defaults.set(newValue, forKey: Keys.analyticsEnabled) }
    }
    
    /// Enable/disable crash reporting
    var crashReportingEnabled: Bool {
        get { defaults.bool(forKey: Keys.crashReportingEnabled) }
        set { defaults.set(newValue, forKey: Keys.crashReportingEnabled) }
    }
    
    // MARK: - Cache Management
    
    /// Get current image cache size
    var imageCacheSize: Int {
        get { defaults.integer(forKey: Keys.imageCacheSize) }
        set { defaults.set(newValue, forKey: Keys.imageCacheSize) }
    }
    
    /// Record cache clear date
    func recordCacheClear() {
        defaults.set(Date(), forKey: Keys.lastCacheClearDate)
    }
    
    /// Get last cache clear date
    var lastCacheClearDate: Date? {
        return defaults.object(forKey: Keys.lastCacheClearDate) as? Date
    }
    
    // MARK: - Reset & Clear
    
    /// Reset all preferences to defaults
    func resetAllPreferences() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        
        // Reload initial values
        hasCompletedOnboarding = false
        notificationsEnabled = false
        selectedTheme = .system
        selectedMeasurementUnit = .metric
        
        Config.Logging.log("All preferences reset", level: .warning)
    }
    
    /// Clear onboarding state (for testing)
    func resetOnboarding() {
        hasCompletedOnboarding = false
        Config.Logging.log("Onboarding reset", level: .info)
    }
    
    /// Force synchronize defaults
    func synchronize() {
        defaults.synchronize()
    }
}

// MARK: - Enums

extension UserDefaultsManager {
    
    /// App theme options
    enum Theme: String, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "System"
            }
        }
    }
    
    /// Measurement unit preferences
    enum MeasurementUnit: String, CaseIterable {
        case metric = "metric"
        case imperial = "imperial"
        
        var displayName: String {
            switch self {
            case .metric: return "Metric (kg, cm)"
            case .imperial: return "Imperial (lbs, in)"
            }
        }
    }
}

// MARK: - Convenience Extensions

extension UserDefaultsManager {
    
    /// Check if app was recently installed (within last 7 days)
    var isRecentInstall: Bool {
        guard let firstLaunch = firstLaunchDate else {
            return true
        }
        let daysSinceInstall = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        return daysSinceInstall <= 7
    }
    
    /// Check if user is active (launched app in last 7 days)
    var isActiveUser: Bool {
        guard let lastLogin = lastLoginDate else {
            return false
        }
        let daysSinceLogin = Calendar.current.dateComponents([.day], from: lastLogin, to: Date()).day ?? 0
        return daysSinceLogin <= 7
    }
}
