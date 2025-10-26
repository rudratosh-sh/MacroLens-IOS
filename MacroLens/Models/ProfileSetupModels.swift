//
//  ProfileSetupModels.swift
//  MacroLens
//
//  Path: MacroLens/Models/ProfileSetupModels.swift
//
//  DEPENDENCIES:
//  - Foundation
//
//  USED BY:
//  - ProfileSetupViewModel
//  - BasicInfoView
//  - ActivityLevelView
//  - GoalsView
//  - DietaryPreferencesView
//
//  PURPOSE:
//  - Data models for 4-step profile setup flow
//  - Aligned with backend API: PUT /api/v1/users/me/profile
//  - Aligned with backend API: PUT /api/v1/users/me/preferences
//

import Foundation

// MARK: - Activity Level (Matches Backend Enum)

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "sedentary"
    case lightlyActive = "lightly_active"
    case moderatelyActive = "moderately_active"
    case veryActive = "very_active"
    case extremelyActive = "extremely_active"
    
    var displayName: String {
        switch self {
        case .sedentary:
            return "Sedentary"
        case .lightlyActive:
            return "Lightly Active"
        case .moderatelyActive:
            return "Moderately Active"
        case .veryActive:
            return "Very Active"
        case .extremelyActive:
            return "Extremely Active"
        }
    }
    
    var description: String {
        switch self {
        case .sedentary:
            return "Little or no exercise, desk job"
        case .lightlyActive:
            return "Light exercise 1-3 days/week"
        case .moderatelyActive:
            return "Moderate exercise 3-5 days/week"
        case .veryActive:
            return "Hard exercise 6-7 days/week"
        case .extremelyActive:
            return "Very hard exercise, physical job"
        }
    }
    
    var icon: String {
        switch self {
        case .sedentary:
            return "chair.fill"
        case .lightlyActive:
            return "figure.walk"
        case .moderatelyActive:
            return "figure.run"
        case .veryActive:
            return "figure.strengthtraining.traditional"
        case .extremelyActive:
            return "figure.hiking"
        }
    }
}

// MARK: - Goal Type (Matches Backend Enum)

enum GoalType: String, Codable, CaseIterable {
    case loseWeight = "lose_weight"
    case maintain = "maintain"
    case gainMuscle = "gain_muscle"
    case improveHealth = "improve_health"
    
    var displayName: String {
        switch self {
        case .loseWeight:
            return "Lose Weight"
        case .maintain:
            return "Maintain Weight"
        case .gainMuscle:
            return "Gain Muscle"
        case .improveHealth:
            return "Improve Health"
        }
    }
    
    var description: String {
        switch self {
        case .loseWeight:
            return "Lose fat and reach your ideal weight"
        case .maintain:
            return "Maintain current weight and stay healthy"
        case .gainMuscle:
            return "Build muscle and gain strength"
        case .improveHealth:
            return "Focus on overall health and wellness"
        }
    }
    
    var icon: String {
        switch self {
        case .loseWeight:
            return "arrow.down.circle.fill"
        case .maintain:
            return "equal.circle.fill"
        case .gainMuscle:
            return "arrow.up.circle.fill"
        case .improveHealth:
            return "heart.circle.fill"
        }
    }
}

// MARK: - Gender (Matches Backend Enum)

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
    
    var displayName: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
        case .preferNotToSay:
            return "Prefer not to say"
        }
    }
}

// MARK: - Dietary Restrictions

enum DietaryRestriction: String, Codable, CaseIterable {
    case vegetarian = "vegetarian"
    case vegan = "vegan"
    case glutenFree = "gluten_free"
    case dairyFree = "dairy_free"
    case nutFree = "nut_free"
    case halal = "halal"
    case kosher = "kosher"
    case keto = "keto"
    case paleo = "paleo"
    case lowCarb = "low_carb"
    
    var displayName: String {
        switch self {
        case .vegetarian:
            return "Vegetarian"
        case .vegan:
            return "Vegan"
        case .glutenFree:
            return "Gluten-Free"
        case .dairyFree:
            return "Dairy-Free"
        case .nutFree:
            return "Nut-Free"
        case .halal:
            return "Halal"
        case .kosher:
            return "Kosher"
        case .keto:
            return "Keto"
        case .paleo:
            return "Paleo"
        case .lowCarb:
            return "Low Carb"
        }
    }
    
    var icon: String {
        switch self {
        case .vegetarian, .vegan:
            return "leaf.fill"
        case .glutenFree:
            return "g.circle.fill"
        case .dairyFree:
            return "drop.fill"
        case .nutFree:
            return "n.circle.fill"
        case .halal, .kosher:
            return "checkmark.seal.fill"
        case .keto, .paleo, .lowCarb:
            return "flame.fill"
        }
    }
}

// MARK: - Common Allergies

enum Allergy: String, Codable, CaseIterable {
    case peanuts = "peanuts"
    case treeNuts = "tree_nuts"
    case milk = "milk"
    case eggs = "eggs"
    case wheat = "wheat"
    case soy = "soy"
    case fish = "fish"
    case shellfish = "shellfish"
    case sesame = "sesame"
    
    var displayName: String {
        switch self {
        case .peanuts:
            return "Peanuts"
        case .treeNuts:
            return "Tree Nuts"
        case .milk:
            return "Milk"
        case .eggs:
            return "Eggs"
        case .wheat:
            return "Wheat"
        case .soy:
            return "Soy"
        case .fish:
            return "Fish"
        case .shellfish:
            return "Shellfish"
        case .sesame:
            return "Sesame"
        }
    }
}

// MARK: - Profile Setup Request (API Payload)

/// Complete profile setup data to send to backend
/// POST /api/v1/users/me/profile
struct ProfileSetupRequest: Codable {
    let age: Int
    let gender: Gender
    let heightCm: Double
    let weightKg: Double
    let targetWeightKg: Double?
    let activityLevel: ActivityLevel
    let goal: GoalType
    
    enum CodingKeys: String, CodingKey {
        case age
        case gender
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case targetWeightKg = "target_weight_kg"
        case activityLevel = "activity_level"
        case goal
    }
}

// MARK: - Preferences Setup Request (API Payload)

/// Dietary preferences to send to backend
/// PUT /api/v1/users/me/preferences
struct PreferencesSetupRequest: Codable {
    let dietaryRestrictions: [DietaryRestriction]
    let allergies: [Allergy]
    let dislikedFoods: [String]?
    let favoriteFoods: [String]?
    let cuisinePreferences: [String]?
    let mealPrepTime: Int?
    let cookingSkill: Int?
    let budgetPerMeal: Double?
    let notificationsEnabled: Bool
    let emailNotifications: Bool
    let reminderTimes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case dietaryRestrictions = "dietary_restrictions"
        case allergies
        case dislikedFoods = "disliked_foods"
        case favoriteFoods = "favorite_foods"
        case cuisinePreferences = "cuisine_preferences"
        case mealPrepTime = "meal_prep_time"
        case cookingSkill = "cooking_skill"
        case budgetPerMeal = "budget_per_meal"
        case notificationsEnabled = "notifications_enabled"
        case emailNotifications = "email_notifications"
        case reminderTimes = "reminder_times"
    }
}

// MARK: - User Profile (Domain Model)

/// Complete user profile from backend
struct UserProfile: Codable, Identifiable {
    let id: String
    let userId: String
    let age: Int
    let gender: Gender
    let heightCm: Double
    let weightKg: Double
    let targetWeightKg: Double?
    let activityLevel: ActivityLevel
    let goal: GoalType
    let dailyCalories: Int
    let dailyProtein: Int
    let dailyCarbs: Int
    let dailyFats: Int
    let bmi: Double?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case age
        case gender
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case targetWeightKg = "target_weight_kg"
        case activityLevel = "activity_level"
        case goal
        case dailyCalories = "daily_calories"
        case dailyProtein = "daily_protein"
        case dailyCarbs = "daily_carbs"
        case dailyFats = "daily_fats"
        case bmi
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - User Preferences (Domain Model)

/// User preferences from backend
struct UserPreferences: Codable, Identifiable {
    let id: String
    let userId: String
    let dietaryRestrictions: [DietaryRestriction]
    let allergies: [Allergy]
    let dislikedFoods: [String]
    let favoriteFoods: [String]
    let cuisinePreferences: [String]
    let mealPrepTime: Int?
    let cookingSkill: Int?
    let budgetPerMeal: Double?
    let notificationsEnabled: Bool
    let emailNotifications: Bool
    let reminderTimes: [String]
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case dietaryRestrictions = "dietary_restrictions"
        case allergies
        case dislikedFoods = "disliked_foods"
        case favoriteFoods = "favorite_foods"
        case cuisinePreferences = "cuisine_preferences"
        case mealPrepTime = "meal_prep_time"
        case cookingSkill = "cooking_skill"
        case budgetPerMeal = "budget_per_meal"
        case notificationsEnabled = "notifications_enabled"
        case emailNotifications = "email_notifications"
        case reminderTimes = "reminder_times"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Profile Response (API Response)

/// API response wrapper for profile
struct ProfileResponse: Codable {
    let success: Bool
    let message: String?
    let data: ProfileData
    
    struct ProfileData: Codable {
        let profile: UserProfile
    }
}

// MARK: - Preferences Response (API Response)

/// API response wrapper for preferences
struct PreferencesResponse: Codable {
    let success: Bool
    let message: String?
    let data: PreferencesData
    
    struct PreferencesData: Codable {
        let preferences: UserPreferences
    }
}

// MARK: - Validation Rules

struct ProfileValidation {
    static func validateAge(_ age: Int) -> Bool {
        return age >= 13 && age <= 120
    }
    
    static func validateHeight(_ heightCm: Double) -> Bool {
        return heightCm >= 100 && heightCm <= 250
    }
    
    static func validateWeight(_ weightKg: Double) -> Bool {
        return weightKg >= 30 && weightKg <= 300
    }
    
    static func validateTargetWeight(_ current: Double, _ target: Double, goal: GoalType) -> Bool {
        switch goal {
        case .loseWeight:
            return target < current && target >= 30
        case .gainMuscle:
            return target > current && target <= 300
        case .maintain, .improveHealth:
            return true
        }
    }
}

// MARK: - Helper Extensions

extension UserProfile {
    /// Calculate BMR (Basal Metabolic Rate) using Harris-Benedict equation
    var bmr: Double {
        switch gender {
        case .male:
            return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * Double(age))
        case .female:
            return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * Double(age))
        case .other, .preferNotToSay:
            // Use average of male/female formulas
            let male = 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * Double(age))
            let female = 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * Double(age))
            return (male + female) / 2
        }
    }
    
    /// Calculate TDEE (Total Daily Energy Expenditure)
    var tdee: Double {
        let multiplier: Double
        switch activityLevel {
        case .sedentary:
            multiplier = 1.2
        case .lightlyActive:
            multiplier = 1.375
        case .moderatelyActive:
            multiplier = 1.55
        case .veryActive:
            multiplier = 1.725
        case .extremelyActive:
            multiplier = 1.9
        }
        return bmr * multiplier
    }
}
