//
//  AnalyticsManager.swift
//  MacroLens
//
//  Path: MacroLens/Core/Analytics/AnalyticsManager.swift
//
//  DEPENDENCIES:
//  - FirebaseAnalytics
//  - Config.swift (for logging)
//
//  USED BY:
//  - ViewModels (to track user actions)
//  - Views (to track screen views)
//  - Services (to track API calls, errors)
//
//  PURPOSE:
//  - Centralized analytics event tracking
//  - Type-safe event names and parameters
//  - User property management
//  - Consistent logging across the app
//

import Foundation
import FirebaseAnalytics

/// Manager for Firebase Analytics event tracking
final class AnalyticsManager {
    
    // MARK: - Singleton
    
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - Screen Tracking
    
    /// Track screen view
    /// - Parameters:
    ///   - screenName: Name of the screen
    ///   - screenClass: Class name of the screen (optional)
    func trackScreenView(_ screenName: String, screenClass: String? = nil) {
        var parameters: [String: Any] = [
            AnalyticsParameterScreenName: screenName
        ]
        
        if let screenClass = screenClass {
            parameters[AnalyticsParameterScreenClass] = screenClass
        }
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
        Config.Logging.log("Screen viewed: \(screenName)", level: .debug)
    }
    
    // MARK: - Authentication Events
    
    /// Track user registration
    /// - Parameter method: Registration method (email, google, apple)
    func trackRegistration(method: String) {
        Analytics.logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
        Config.Logging.log("User registered: \(method)", level: .info)
    }
    
    /// Track user login
    /// - Parameter method: Login method (email, google, apple, biometric)
    func trackLogin(method: String) {
        Analytics.logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
        Config.Logging.log("User logged in: \(method)", level: .info)
    }
    
    /// Track user logout
    func trackLogout() {
        Analytics.logEvent("logout", parameters: nil)
        Config.Logging.log("User logged out", level: .info)
    }
    
    // MARK: - Food Tracking Events
    
    /// Track food scan
    /// - Parameters:
    ///   - success: Whether scan was successful
    ///   - recognitionTime: Time taken for recognition (in seconds)
    func trackFoodScan(success: Bool, recognitionTime: Double? = nil) {
        var parameters: [String: Any] = [
            "success": success
        ]
        
        if let time = recognitionTime {
            parameters["recognition_time"] = time
        }
        
        Analytics.logEvent("food_scanned", parameters: parameters)
        Config.Logging.log("Food scanned - Success: \(success)", level: .debug)
    }
    
    /// Track manual food logging
    /// - Parameters:
    ///   - mealType: Type of meal (breakfast, lunch, dinner, snack)
    ///   - calories: Calorie amount
    ///   - source: Source of food data (custom, database, scan)
    func trackFoodLogged(mealType: String, calories: Int, source: String) {
        Analytics.logEvent("food_logged", parameters: [
            "meal_type": mealType,
            "calories": calories,
            "source": source
        ])
        Config.Logging.log("Food logged: \(mealType) - \(calories) cal", level: .debug)
    }
    
    /// Track food log deletion
    /// - Parameter mealType: Type of meal deleted
    func trackFoodDeleted(mealType: String) {
        Analytics.logEvent("food_deleted", parameters: [
            "meal_type": mealType
        ])
        Config.Logging.log("Food deleted: \(mealType)", level: .debug)
    }
    
    // MARK: - Recipe Events
    
    /// Track recipe view
    /// - Parameters:
    ///   - recipeId: Recipe identifier
    ///   - recipeName: Recipe name
    func trackRecipeViewed(recipeId: String, recipeName: String) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: recipeId,
            AnalyticsParameterItemName: recipeName,
            AnalyticsParameterContentType: "recipe"
        ])
        Config.Logging.log("Recipe viewed: \(recipeName)", level: .debug)
    }
    
    /// Track recipe favorite
    /// - Parameters:
    ///   - recipeId: Recipe identifier
    ///   - isFavorited: Whether favorited or unfavorited
    func trackRecipeFavorite(recipeId: String, isFavorited: Bool) {
        Analytics.logEvent("recipe_favorite", parameters: [
            "recipe_id": recipeId,
            "action": isFavorited ? "add" : "remove"
        ])
        Config.Logging.log("Recipe favorite: \(isFavorited)", level: .debug)
    }
    
    // MARK: - Progress Events
    
    /// Track weight logging
    /// - Parameter weight: Weight value
    func trackWeightLogged(weight: Double) {
        Analytics.logEvent("weight_logged", parameters: [
            "weight": weight
        ])
        Config.Logging.log("Weight logged: \(weight)", level: .debug)
    }
    
    /// Track water logging
    /// - Parameter amount: Water amount in ml
    func trackWaterLogged(amount: Int) {
        Analytics.logEvent("water_logged", parameters: [
            "amount_ml": amount
        ])
        Config.Logging.log("Water logged: \(amount)ml", level: .debug)
    }
    
    /// Track goal achievement
    /// - Parameters:
    ///   - goalType: Type of goal achieved
    ///   - value: Goal value achieved
    func trackGoalAchieved(goalType: String, value: Double) {
        Analytics.logEvent("goal_achieved", parameters: [
            "goal_type": goalType,
            "value": value
        ])
        Config.Logging.log("Goal achieved: \(goalType)", level: .info)
    }
    
    // MARK: - Meal Planning Events
    
    /// Track meal plan generation
    /// - Parameters:
    ///   - duration: Duration in days
    ///   - success: Whether generation was successful
    func trackMealPlanGenerated(duration: Int, success: Bool) {
        Analytics.logEvent("meal_plan_generated", parameters: [
            "duration_days": duration,
            "success": success
        ])
        Config.Logging.log("Meal plan generated: \(duration) days", level: .debug)
    }
    
    // MARK: - Settings Events
    
    /// Track settings change
    /// - Parameters:
    ///   - setting: Setting name
    ///   - value: New value
    func trackSettingChanged(setting: String, value: Any) {
        Analytics.logEvent("setting_changed", parameters: [
            "setting_name": setting,
            "new_value": "\(value)"
        ])
        Config.Logging.log("Setting changed: \(setting)", level: .debug)
    }
    
    /// Track notification permission
    /// - Parameter granted: Whether permission was granted
    func trackNotificationPermission(granted: Bool) {
        Analytics.logEvent("notification_permission", parameters: [
            "granted": granted
        ])
        Config.Logging.log("Notification permission: \(granted)", level: .info)
    }
    
    /// Track HealthKit permission
    /// - Parameter granted: Whether permission was granted
    func trackHealthKitPermission(granted: Bool) {
        Analytics.logEvent("healthkit_permission", parameters: [
            "granted": granted
        ])
        Config.Logging.log("HealthKit permission: \(granted)", level: .info)
    }
    
    // MARK: - Error Tracking
    
    /// Track API error
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - statusCode: HTTP status code
    ///   - errorMessage: Error message
    func trackAPIError(endpoint: String, statusCode: Int, errorMessage: String) {
        Analytics.logEvent("api_error", parameters: [
            "endpoint": endpoint,
            "status_code": statusCode,
            "error_message": errorMessage
        ])
        Config.Logging.log("API Error: \(endpoint) - \(statusCode)", level: .error)
    }
    
    /// Track general error
    /// - Parameters:
    ///   - errorType: Type of error
    ///   - errorMessage: Error message
    func trackError(errorType: String, errorMessage: String) {
        Analytics.logEvent("app_error", parameters: [
            "error_type": errorType,
            "error_message": errorMessage
        ])
        Config.Logging.log("Error: \(errorType) - \(errorMessage)", level: .error)
    }
    
    // MARK: - User Properties
    
    /// Set user ID
    /// - Parameter userId: User identifier
    func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
        Config.Logging.log("User ID set: \(userId)", level: .info)
    }
    
    /// Clear user ID (on logout)
    func clearUserId() {
        Analytics.setUserID(nil)
        Config.Logging.log("User ID cleared", level: .info)
    }
    
    /// Set user property
    /// - Parameters:
    ///   - property: Property name
    ///   - value: Property value
    func setUserProperty(_ property: String, value: String?) {
        Analytics.setUserProperty(value, forName: property)
        Config.Logging.log("User property set: \(property)", level: .debug)
    }
    
    /// Set user goal type
    /// - Parameter goalType: User's goal type
    func setUserGoalType(_ goalType: String) {
        setUserProperty("goal_type", value: goalType)
    }
    
    /// Set user activity level
    /// - Parameter activityLevel: User's activity level
    func setUserActivityLevel(_ activityLevel: String) {
        setUserProperty("activity_level", value: activityLevel)
    }
    
    /// Set user subscription status
    /// - Parameter isPremium: Whether user has premium subscription
    func setSubscriptionStatus(isPremium: Bool) {
        setUserProperty("subscription_status", value: isPremium ? "premium" : "free")
    }
    
    // MARK: - Custom Events
    
    /// Track custom event
    /// - Parameters:
    ///   - eventName: Event name
    ///   - parameters: Event parameters
    func trackCustomEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(eventName, parameters: parameters)
        Config.Logging.log("Custom event: \(eventName)", level: .debug)
    }
}

// MARK: - Usage Examples

/*
 
 // MARK: - Screen Tracking
 
 // In a View's onAppear
 AnalyticsManager.shared.trackScreenView("Home")
 AnalyticsManager.shared.trackScreenView("Profile", screenClass: "ProfileView")
 
 
 // MARK: - Authentication
 
 // After successful registration
 AnalyticsManager.shared.trackRegistration(method: "email")
 AnalyticsManager.shared.trackRegistration(method: "google")
 
 // After successful login
 AnalyticsManager.shared.trackLogin(method: "email")
 AnalyticsManager.shared.trackLogin(method: "biometric")
 
 // On logout
 AnalyticsManager.shared.trackLogout()
 
 
 // MARK: - Food Tracking
 
 // After food scan
 AnalyticsManager.shared.trackFoodScan(success: true, recognitionTime: 2.5)
 
 // After logging food
 AnalyticsManager.shared.trackFoodLogged(
     mealType: "breakfast",
     calories: 350,
     source: "scan"
 )
 
 
 // MARK: - User Properties
 
 // After login
 AnalyticsManager.shared.setUserId(user.id)
 AnalyticsManager.shared.setUserGoalType("lose_weight")
 AnalyticsManager.shared.setUserActivityLevel("moderately_active")
 
 // On logout
 AnalyticsManager.shared.clearUserId()
 
 
 // MARK: - Error Tracking
 
 // API error
 AnalyticsManager.shared.trackAPIError(
     endpoint: "/food/logs",
     statusCode: 500,
     errorMessage: "Server error"
 )
 
 // General error
 AnalyticsManager.shared.trackError(
     errorType: "CoreML",
     errorMessage: "Model inference failed"
 )
 
 */
