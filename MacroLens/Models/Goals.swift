//
//  Goals.swift
//  MacroLens
//
//  Path: MacroLens/Models/Goals.swift
//
//  DEPENDENCIES:
//  - User.swift (GoalType enum already defined)
//
//  USED BY:
//  - ProfileViewModel
//  - DashboardViewModel
//  - NutritionService
//
//  PURPOSE:
//  - User's nutrition goals and targets
//  - Daily macro targets (calories, protein, carbs, fats)
//  - Goal tracking and progress calculation
//

import Foundation

// MARK: - Goals Model

/// User's nutrition goals and daily targets
struct Goals: Codable, Identifiable, Sendable {
    let id: String
    let userId: String
    let goalType: GoalType
    let targetWeight: Double? // in kg
    let weeklyWeightChange: Double? // kg per week (positive for gain, negative for loss)
    let activityLevel: ActivityLevel
    
    // Daily Targets
    let dailyCalories: Int
    let dailyProtein: Double // grams
    let dailyCarbs: Double // grams
    let dailyFats: Double // grams
    let dailyWater: Int? // ml
    
    // Metadata
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case goalType = "goal_type"
        case targetWeight = "target_weight"
        case weeklyWeightChange = "weekly_weight_change"
        case activityLevel = "activity_level"
        case dailyCalories = "daily_calories"
        case dailyProtein = "daily_protein"
        case dailyCarbs = "daily_carbs"
        case dailyFats = "daily_fats"
        case dailyWater = "daily_water"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Goals Update Request

/// Request to update user goals
struct GoalsUpdateRequest: Codable, Sendable {
    let goalType: GoalType
    let targetWeight: Double?
    let weeklyWeightChange: Double?
    let activityLevel: ActivityLevel
    let dailyCalories: Int
    let dailyProtein: Double
    let dailyCarbs: Double
    let dailyFats: Double
    let dailyWater: Int?
    
    enum CodingKeys: String, CodingKey {
        case goalType = "goal_type"
        case targetWeight = "target_weight"
        case weeklyWeightChange = "weekly_weight_change"
        case activityLevel = "activity_level"
        case dailyCalories = "daily_calories"
        case dailyProtein = "daily_protein"
        case dailyCarbs = "daily_carbs"
        case dailyFats = "daily_fats"
        case dailyWater = "daily_water"
    }
}

// MARK: - Goals Extensions

extension Goals {
    
    /// Calculate total macro calories
    var totalMacroCalories: Int {
        let proteinCals = dailyProtein * 4 // 4 cal/g
        let carbsCals = dailyCarbs * 4 // 4 cal/g
        let fatsCals = dailyFats * 9 // 9 cal/g
        return Int(proteinCals + carbsCals + fatsCals)
    }
    
    /// Macro distribution percentages
    var macroPercentages: (protein: Int, carbs: Int, fats: Int) {
        let totalCals = Double(totalMacroCalories)
        guard totalCals > 0 else { return (0, 0, 0) }
        
        let proteinPercent = Int((dailyProtein * 4 / totalCals) * 100)
        let carbsPercent = Int((dailyCarbs * 4 / totalCals) * 100)
        let fatsPercent = Int((dailyFats * 9 / totalCals) * 100)
        
        return (proteinPercent, carbsPercent, fatsPercent)
    }
    
    /// Get goal description
    var goalDescription: String {
        switch goalType {
        case .loseWeight:
            return "Lose Weight"
        case .maintainWeight:
            return "Maintain Weight"
        case .gainWeight:
            return "Gain Weight"
        case .buildMuscle:
            return "Build Muscle"
        }
    }
    
    /// Get activity level description
    var activityDescription: String {
        switch activityLevel {
        case .sedentary:
            return "Sedentary (little or no exercise)"
        case .lightlyActive:
            return "Lightly Active (1-3 days/week)"
        case .moderatelyActive:
            return "Moderately Active (3-5 days/week)"
        case .veryActive:
            return "Very Active (6-7 days/week)"
        case .extraActive:
            return "Extra Active (athlete, 2x/day)"
        }
    }
    
    /// Weekly weight change description
    var weeklyChangeDescription: String? {
        guard let change = weeklyWeightChange else { return nil }
        
        if change > 0 {
            return "+\(String(format: "%.1f", change)) kg/week"
        } else if change < 0 {
            return "\(String(format: "%.1f", change)) kg/week"
        } else {
            return "Maintain current weight"
        }
    }
}

// MARK: - Mock Data

extension Goals {
    
    /// Mock goals for preview/testing
    static var mock: Goals {
        return Goals(
            id: "goals_123",
            userId: "user_123",
            goalType: .loseWeight,
            targetWeight: 75.0,
            weeklyWeightChange: -0.5,
            activityLevel: .moderatelyActive,
            dailyCalories: 2000,
            dailyProtein: 150.0,
            dailyCarbs: 200.0,
            dailyFats: 65.0,
            dailyWater: 3000,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
    }
}
