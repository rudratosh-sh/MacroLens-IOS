//
//  Constants.swift
//  MacroLens
//
//  App-wide constants and values
//

import Foundation
import SwiftUI

struct Constants {
    
    // MARK: - Nutrition
    struct Nutrition {
        // Macronutrient calories per gram
        static let caloriesPerGramProtein: Double = 4.0
        static let caloriesPerGramCarb: Double = 4.0
        static let caloriesPerGramFat: Double = 9.0
        static let caloriesPerGramAlcohol: Double = 7.0
        
        // Default macro ratios (%)
        static let defaultProteinRatio: Double = 30.0
        static let defaultCarbRatio: Double = 40.0
        static let defaultFatRatio: Double = 30.0
        
        // Minimum/Maximum daily values
        static let minDailyCalories: Double = 1200.0
        static let maxDailyCalories: Double = 5000.0
        static let minProteinGrams: Double = 50.0
        static let maxProteinGrams: Double = 400.0
    }
    
    // MARK: - Units
    struct Units {
        static let weightUnits = ["g", "kg", "oz", "lb"]
        static let volumeUnits = ["ml", "l", "cup", "tbsp", "tsp", "fl oz"]
        static let servingUnits = ["serving", "piece", "slice", "whole"]
        
        // Conversion factors (to grams)
        static let ozToGrams: Double = 28.3495
        static let lbToGrams: Double = 453.592
        static let cupToMl: Double = 236.588
        static let tbspToMl: Double = 14.7868
        static let tspToMl: Double = 4.92892
    }
    
    // MARK: - UI Values
    struct UI {
        // Spacing
        static let spacing4: CGFloat = 4
        static let spacing8: CGFloat = 8
        static let spacing12: CGFloat = 12
        static let spacing16: CGFloat = 16
        static let spacing20: CGFloat = 20
        static let spacing24: CGFloat = 24
        static let spacing32: CGFloat = 32
        static let spacing40: CGFloat = 40
        static let spacing64: CGFloat = 64
        
        // Corner Radius
        static let cornerRadiusSmall: CGFloat = 8
        static let cornerRadiusMedium: CGFloat = 12
        static let cornerRadiusLarge: CGFloat = 16
        static let cornerRadiusXLarge: CGFloat = 24
        
        // Border Width
        static let borderWidthThin: CGFloat = 1
        static let borderWidthMedium: CGFloat = 2
        static let borderWidthThick: CGFloat = 3
        
        // Icon Sizes
        static let iconSizeSmall: CGFloat = 16
        static let iconSizeMedium: CGFloat = 24
        static let iconSizeLarge: CGFloat = 32
        static let iconSizeXLarge: CGFloat = 48
        
        // Button Heights
        static let buttonHeightSmall: CGFloat = 40
        static let buttonHeightMedium: CGFloat = 48
        static let buttonHeightLarge: CGFloat = 56
        
        // Animation
        static let animationDurationFast: Double = 0.2
        static let animationDurationMedium: Double = 0.3
        static let animationDurationSlow: Double = 0.5
    }
    
    // MARK: - Images
    struct Images {
        // SF Symbols
        static let home = "house.fill"
        static let search = "magnifyingglass"
        static let camera = "camera.fill"
        static let profile = "person.fill"
        static let settings = "gearshape.fill"
        static let add = "plus.circle.fill"
        static let edit = "pencil"
        static let delete = "trash"
        static let check = "checkmark.circle.fill"
        static let close = "xmark"
        static let back = "chevron.left"
        static let forward = "chevron.right"
        static let info = "info.circle"
        static let warning = "exclamationmark.triangle"
        static let success = "checkmark.circle"
        static let error = "xmark.circle"
        
        // Food Categories
        static let foodGeneral = "fork.knife"
        static let protein = "flame.fill"
        static let carbs = "leaf.fill"
        static let fats = "drop.fill"
        static let water = "drop.fill"
        static let fruit = "apple.logo"
        static let vegetable = "leaf"
        
        // Progress
        static let chart = "chart.bar.fill"
        static let trophy = "trophy.fill"
        static let calendar = "calendar"
        static let clock = "clock.fill"
    }
    
    // MARK: - Validation
    struct Validation {
        static let minPasswordLength = 8
        static let maxPasswordLength = 128
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        static let minUsernameLength = 3
        static let maxUsernameLength = 30
        static let maxBioLength = 500
    }
    
    // MARK: - Dates
    struct Dates {
        static let dateFormat = "yyyy-MM-dd"
        static let timeFormat = "HH:mm"
        static let dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss"
        static let displayDateFormat = "MMM d, yyyy"
        static let displayTimeFormat = "h:mm a"
    }
    
    // MARK: - Notifications
    struct Notifications {
        // Local notification identifiers
        static let mealReminder = "meal_reminder"
        static let waterReminder = "water_reminder"
        static let goalAchieved = "goal_achieved"
        static let streakMilestone = "streak_milestone"
        
        // Categories
        static let mealReminderCategory = "MEAL_REMINDER"
        static let achievementCategory = "ACHIEVEMENT"
    }
    
    // MARK: - HealthKit
    struct HealthKit {
        static let readPermissions = [
            "HKQuantityTypeIdentifierActiveEnergyBurned",
            "HKQuantityTypeIdentifierBasalEnergyBurned",
            "HKQuantityTypeIdentifierStepCount",
            "HKQuantityTypeIdentifierHeight",
            "HKQuantityTypeIdentifierBodyMass"
        ]
        
        static let writePermissions = [
            "HKQuantityTypeIdentifierDietaryEnergyConsumed",
            "HKQuantityTypeIdentifierDietaryProtein",
            "HKQuantityTypeIdentifierDietaryCarbohydrates",
            "HKQuantityTypeIdentifierDietaryFatTotal"
        ]
    }
    
    // MARK: - Limits
    struct Limits {
        static let maxPhotosPerMeal = 5
        static let maxCustomFoodsPerUser = 100
        static let maxFavoriteFoodsPerUser = 50
        static let maxRecentSearches = 20
        static let maxMealPlanDays = 14
        static let maxRecipeIngredients = 30
    }
    
    // MARK: - Cache
    struct Cache {
        static let foodSearchCacheDuration: TimeInterval = 3600 // 1 hour
        static let recipeCacheDuration: TimeInterval = 86400 // 24 hours
        static let userDataCacheDuration: TimeInterval = 300 // 5 minutes
        static let maxCacheSize: Int = 50 * 1024 * 1024 // 50 MB
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let genericError = "Something went wrong. Please try again."
        static let networkError = "Unable to connect. Check your internet connection."
        static let authenticationError = "Authentication failed. Please log in again."
        static let validationError = "Please check your input and try again."
        static let notFoundError = "The requested item could not be found."
        static let serverError = "Server error. Please try again later."
        static let timeoutError = "Request timed out. Please try again."
        static let unauthorizedError = "You don't have permission to access this."
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static let loginSuccess = "Welcome back!"
        static let registrationSuccess = "Account created successfully!"
        static let profileUpdated = "Profile updated successfully"
        static let foodLogged = "Food logged successfully"
        static let goalSet = "Goal set successfully"
        static let dataSync = "Data synced with HealthKit"
    }
}
