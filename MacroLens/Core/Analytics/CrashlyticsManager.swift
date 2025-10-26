//
//  CrashlyticsManager.swift
//  MacroLens
//
//  Path: MacroLens/Core/Analytics/CrashlyticsManager.swift
//
//  DEPENDENCIES:
//  - FirebaseCrashlytics
//  - Config.swift (for logging)
//
//  USED BY:
//  - ViewModels (to log non-fatal errors)
//  - Services (to log API failures)
//  - Utilities (to log processing errors)
//
//  PURPOSE:
//  - Centralized crash reporting
//  - Non-fatal error logging
//  - Custom key/value logging for debugging
//  - User identification for crash reports
//

import Foundation
import FirebaseCrashlytics

/// Manager for Firebase Crashlytics error reporting
final class CrashlyticsManager {
    
    // MARK: - Singleton
    
    static let shared = CrashlyticsManager()
    
    private let crashlytics = Crashlytics.crashlytics()
    
    private init() {}
    
    // MARK: - User Identification
    
    /// Set user identifier for crash reports
    /// - Parameter userId: User identifier
    func setUserId(_ userId: String) {
        crashlytics.setUserID(userId)
        Config.Logging.log("Crashlytics user ID set: \(userId)", level: .info)
    }
    
    /// Clear user identifier (on logout)
    func clearUserId() {
        crashlytics.setUserID("")
        Config.Logging.log("Crashlytics user ID cleared", level: .info)
    }
    
    // MARK: - Custom Keys
    
    /// Set custom key for crash context
    /// - Parameters:
    ///   - key: Key name
    ///   - value: Value (String, Int, Bool, Double)
    func setCustomKey(_ key: String, value: Any) {
        if let stringValue = value as? String {
            crashlytics.setCustomValue(stringValue, forKey: key)
        } else if let intValue = value as? Int {
            crashlytics.setCustomValue(intValue, forKey: key)
        } else if let boolValue = value as? Bool {
            crashlytics.setCustomValue(boolValue, forKey: key)
        } else if let doubleValue = value as? Double {
            crashlytics.setCustomValue(doubleValue, forKey: key)
        } else {
            crashlytics.setCustomValue("\(value)", forKey: key)
        }
        
        Config.Logging.log("Crashlytics custom key set: \(key)", level: .debug)
    }
    
    /// Set multiple custom keys at once
    /// - Parameter keyValues: Dictionary of key-value pairs
    func setCustomKeys(_ keyValues: [String: Any]) {
        keyValues.forEach { key, value in
            setCustomKey(key, value: value)
        }
    }
    
    // MARK: - Logging
    
    /// Log message to Crashlytics
    /// - Parameter message: Log message
    func log(_ message: String) {
        crashlytics.log(message)
        Config.Logging.log("Crashlytics log: \(message)", level: .debug)
    }
    
    /// Log formatted message with timestamp
    /// - Parameters:
    ///   - message: Log message
    ///   - metadata: Optional metadata dictionary
    func logWithMetadata(_ message: String, metadata: [String: Any]? = nil) {
        var logMessage = "[\(Date().ISO8601Format())] \(message)"
        
        if let metadata = metadata {
            let metadataString = metadata.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            logMessage += " | \(metadataString)"
        }
        
        crashlytics.log(logMessage)
        Config.Logging.log(logMessage, level: .debug)
    }
    
    // MARK: - Error Recording
    
    /// Record non-fatal error
    /// - Parameters:
    ///   - error: Error to record
    ///   - additionalInfo: Optional additional context
    func recordError(_ error: Error, additionalInfo: [String: Any]? = nil) {
        // Set additional context if provided
        if let info = additionalInfo {
            setCustomKeys(info)
        }
        
        // Record error
        crashlytics.record(error: error)
        
        Config.Logging.log("Crashlytics error recorded: \(error.localizedDescription)", level: .error)
    }
    
    /// Record custom error with domain and code
    /// - Parameters:
    ///   - domain: Error domain
    ///   - code: Error code
    ///   - message: Error message
    ///   - additionalInfo: Optional additional context
    func recordCustomError(
        domain: String,
        code: Int,
        message: String,
        additionalInfo: [String: Any]? = nil
    ) {
        let error = NSError(
            domain: domain,
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        
        recordError(error, additionalInfo: additionalInfo)
    }
    
    // MARK: - API Error Recording
    
    /// Record API error
    /// - Parameters:
    ///   - endpoint: API endpoint
    ///   - statusCode: HTTP status code
    ///   - errorMessage: Error message
    ///   - requestBody: Optional request body for context
    func recordAPIError(
        endpoint: String,
        statusCode: Int,
        errorMessage: String,
        requestBody: [String: Any]? = nil
    ) {
        var info: [String: Any] = [
            "endpoint": endpoint,
            "status_code": statusCode,
            "error_type": "api_error"
        ]
        
        if let body = requestBody {
            info["request_body"] = body
        }
        
        recordCustomError(
            domain: "MacroLens.API",
            code: statusCode,
            message: "\(endpoint): \(errorMessage)",
            additionalInfo: info
        )
    }
    
    // MARK: - Specific Error Types
    
    /// Record authentication error
    /// - Parameters:
    ///   - errorType: Type of auth error (login, register, token_refresh)
    ///   - message: Error message
    func recordAuthError(errorType: String, message: String) {
        recordCustomError(
            domain: "MacroLens.Auth",
            code: -1,
            message: message,
            additionalInfo: ["auth_error_type": errorType]
        )
    }
    
    /// Record network error
    /// - Parameters:
    ///   - errorType: Type of network error (connection, timeout, dns)
    ///   - message: Error message
    func recordNetworkError(errorType: String, message: String) {
        recordCustomError(
            domain: "MacroLens.Network",
            code: -1,
            message: message,
            additionalInfo: ["network_error_type": errorType]
        )
    }
    
    /// Record Core ML error
    /// - Parameters:
    ///   - modelName: Name of ML model
    ///   - message: Error message
    func recordMLError(modelName: String, message: String) {
        recordCustomError(
            domain: "MacroLens.CoreML",
            code: -1,
            message: message,
            additionalInfo: ["model_name": modelName]
        )
    }
    
    /// Record Core Data error
    /// - Parameters:
    ///   - operation: Core Data operation (save, fetch, delete)
    ///   - entityName: Entity name
    ///   - message: Error message
    func recordCoreDataError(operation: String, entityName: String, message: String) {
        recordCustomError(
            domain: "MacroLens.CoreData",
            code: -1,
            message: message,
            additionalInfo: [
                "operation": operation,
                "entity_name": entityName
            ]
        )
    }
    
    /// Record HealthKit error
    /// - Parameters:
    ///   - operation: HealthKit operation (read, write, authorize)
    ///   - message: Error message
    func recordHealthKitError(operation: String, message: String) {
        recordCustomError(
            domain: "MacroLens.HealthKit",
            code: -1,
            message: message,
            additionalInfo: ["healthkit_operation": operation]
        )
    }
    
    /// Record image processing error
    /// - Parameters:
    ///   - operation: Image operation (compression, upload, processing)
    ///   - message: Error message
    func recordImageError(operation: String, message: String) {
        recordCustomError(
            domain: "MacroLens.Image",
            code: -1,
            message: message,
            additionalInfo: ["image_operation": operation]
        )
    }
    
    // MARK: - Breadcrumbs
    
    /// Log user action breadcrumb
    /// - Parameters:
    ///   - action: User action
    ///   - screen: Current screen
    func logUserAction(_ action: String, screen: String) {
        log("User Action: \(action) on \(screen)")
    }
    
    /// Log navigation breadcrumb
    /// - Parameters:
    ///   - from: Source screen
    ///   - to: Destination screen
    func logNavigation(from: String, to: String) {
        log("Navigation: \(from) → \(to)")
    }
    
    /// Log state change breadcrumb
    /// - Parameters:
    ///   - state: State name
    ///   - value: New value
    func logStateChange(state: String, value: String) {
        log("State Change: \(state) = \(value)")
    }
    
    // MARK: - Testing (Debug only)
    
    #if DEBUG
    /// Force a test crash (debug only)
    func testCrash() {
        fatalError("Test crash triggered")
    }
    
    /// Send test non-fatal error
    func testNonFatalError() {
        let error = NSError(
            domain: "MacroLens.Test",
            code: -999,
            userInfo: [NSLocalizedDescriptionKey: "This is a test non-fatal error"]
        )
        recordError(error, additionalInfo: ["test": true])
    }
    #endif
}

// MARK: - Usage Examples

/*
 
 // MARK: - User Identification
 
 // After login
 CrashlyticsManager.shared.setUserId(user.id)
 
 // On logout
 CrashlyticsManager.shared.clearUserId()
 
 
 // MARK: - Custom Keys (for crash context)
 
 CrashlyticsManager.shared.setCustomKey("current_screen", value: "Home")
 CrashlyticsManager.shared.setCustomKey("user_goal", value: "lose_weight")
 CrashlyticsManager.shared.setCustomKey("is_premium", value: false)
 
 // Multiple keys at once
 CrashlyticsManager.shared.setCustomKeys([
     "meal_type": "breakfast",
     "calories": 350,
     "logged_today": true
 ])
 
 
 // MARK: - Logging
 
 CrashlyticsManager.shared.log("User tapped scan button")
 CrashlyticsManager.shared.logWithMetadata(
     "Food scan initiated",
     metadata: ["meal_type": "lunch", "source": "camera"]
 )
 
 
 // MARK: - Error Recording
 
 // Record any error
 do {
     try somethingThatMightFail()
 } catch {
     CrashlyticsManager.shared.recordError(error)
 }
 
 // Record error with context
 CrashlyticsManager.shared.recordError(
     error,
     additionalInfo: [
         "user_action": "logging_food",
         "meal_type": "dinner"
     ]
 )
 
 
 // MARK: - Specific Error Types
 
 // API error
 CrashlyticsManager.shared.recordAPIError(
     endpoint: "/food/logs",
     statusCode: 500,
     errorMessage: "Internal server error",
     requestBody: ["food_id": "123"]
 )
 
 // Auth error
 CrashlyticsManager.shared.recordAuthError(
     errorType: "token_refresh",
     message: "Failed to refresh access token"
 )
 
 // Network error
 CrashlyticsManager.shared.recordNetworkError(
     errorType: "timeout",
     message: "Request timed out after 30 seconds"
 )
 
 // Core ML error
 CrashlyticsManager.shared.recordMLError(
     modelName: "FoodClassifier",
     message: "Model inference failed"
 )
 
 // Core Data error
 CrashlyticsManager.shared.recordCoreDataError(
     operation: "save",
     entityName: "FoodLogEntity",
     message: "Failed to save food log"
 )
 
 // HealthKit error
 CrashlyticsManager.shared.recordHealthKitError(
     operation: "read",
     message: "Failed to read step count"
 )
 
 
 // MARK: - Breadcrumbs
 
 // User actions
 CrashlyticsManager.shared.logUserAction("scan_food", screen: "Home")
 
 // Navigation
 CrashlyticsManager.shared.logNavigation(from: "Home", to: "Profile")
 
 // State changes
 CrashlyticsManager.shared.logStateChange(state: "auth_status", value: "logged_in")
 
 
 // MARK: - Testing (Debug only)
 
 #if DEBUG
 // Test crash (will crash the app)
 CrashlyticsManager.shared.testCrash()
 
 // Test non-fatal error (won't crash)
 CrashlyticsManager.shared.testNonFatalError()
 #endif
 
 */
