
//
//  Config.swift
//  MacroLens
//
//  Environment configuration and API endpoints
//

import Foundation

enum Environment {
    case development
    case staging
    case production
    
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}

struct Config {
    
    // MARK: - Environment
    static let environment = Environment.current
    
    // MARK: - API Configuration
    struct API {
        static var baseURL: String {
            switch environment {
            case .development:
                return "http://localhost:8000"
            case .staging:
                return "https://macrolens-api-staging.up.railway.app"
            case .production:
                return "https://macrolens-api.up.railway.app"
            }
        }
        
        static let version = "v1"
        static var fullBaseURL: String {
            return "\(baseURL)/api/\(version)"
        }
        
        // Timeout configurations
        static let requestTimeout: TimeInterval = 30.0
        static let resourceTimeout: TimeInterval = 60.0
    }
    
    // MARK: - Endpoints
    struct Endpoints {
        // Auth
        static let register = "/auth/register"
        static let login = "/auth/login"
        static let refreshToken = "/auth/refresh"
        static let logout = "/auth/logout"
        static let verifyEmail = "/auth/verify-email"
        static let resetPassword = "/auth/reset-password"
        
        // Users
        static let userProfile = "/users/profile"
        static let updateProfile = "/users/profile"
        static let deleteAccount = "/users/account"
        static let userPreferences = "/users/preferences"
        
        // Food
        static let foodSearch = "/food/search"
        static let foodDetails = "/food"
        static let scanFood = "/food/scan"
        static let customFood = "/food/custom"
        
        // Food Logs
        static let foodLogs = "/food/logs"
        static let todayLogs = "/food/logs/today"
        static let logsByDate = "/food/logs/date"
        
        // Nutrition
        static let nutritionGoals = "/nutrition/goals"
        static let dailyNutrition = "/nutrition/daily"
        static let macroBreakdown = "/nutrition/macros"
        
        // Recipes
        static let recipes = "/recipes"
        static let recipeSearch = "/recipes/search"
        static let favoriteRecipes = "/recipes/favorites"
        
        // Meal Plans
        static let mealPlans = "/meal-plans"
        static let generateMealPlan = "/meal-plans/generate"
        static let activeMealPlan = "/meal-plans/active"
        
        // Progress
        static let progress = "/progress"
        static let progressHistory = "/progress/history"
        static let progressStats = "/progress/stats"
        
        // Health Integration
        static let healthSync = "/health/sync"
        static let healthData = "/health/data"
    }
    
    // MARK: - App Configuration
    struct App {
        static let name = "MacroLens"
        static let bundleIdentifier = "com.macrolens.MacroLens"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        static let appStoreURL = "https://apps.apple.com/app/macrolens/id[YOUR_APP_ID]"
        static let websiteURL = "https://macrolens.in"
        static let supportEmail = "support@macrolens.in"
        static let privacyPolicyURL = "https://macrolens.in/privacy"
        static let termsOfServiceURL = "https://macrolens.in/terms"
    }
    
    // MARK: - Feature Flags
    struct Features {
        static let enableHealthKit = true
        static let enableBarcodeScanning = true
        static let enableAIMealPlanning = true
        static let enableRecipes = true
        static let enableSocialSharing = false // Phase 2
        static let enablePremiumFeatures = false // Phase 2
    }
    
    // MARK: - Storage Keys
    struct StorageKeys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let userId = "user_id"
        static let userEmail = "user_email"
        static let onboardingCompleted = "onboarding_completed"
        static let healthKitAuthorized = "healthkit_authorized"
        static let notificationsEnabled = "notifications_enabled"
    }
    
    // MARK: - Logging
    struct Logging {
        static var isEnabled: Bool {
            return environment == .development
        }
        
        static func log(_ message: String, level: LogLevel = .info) {
            guard isEnabled else { return }
            
            let timestamp = Date().formatted(date: .omitted, time: .standard)
            let prefix = "[\(level.rawValue)] [\(timestamp)]"
            print("\(prefix) \(message)")
        }
    }
    
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
}
