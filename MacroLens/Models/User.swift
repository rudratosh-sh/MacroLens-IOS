//
//  User.swift
//  MacroLens
//
//  Path: MacroLens/Models/User.swift
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable,Sendable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let username: String?
    let profileImageUrl: String?
    let isEmailVerified: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // Profile details
    let age: Int?
    let gender: Gender?
    let height: Double? // in cm
    let weight: Double? // in kg
    let activityLevel: ActivityLevel?
    
    // Goals
    let goalType: GoalType?
    let targetWeight: Double?
    let targetCalories: Double?
    let targetProtein: Double?
    let targetCarbs: Double?
    let targetFat: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case profileImageUrl = "profile_image_url"
        case isEmailVerified = "is_email_verified"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case age
        case gender
        case height
        case weight
        case activityLevel = "activity_level"
        case goalType = "goal_type"
        case targetWeight = "target_weight"
        case targetCalories = "target_calories"
        case targetProtein = "target_protein"
        case targetCarbs = "target_carbs"
        case targetFat = "target_fat"
    }
    
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        let name = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? (username ?? email) : name
    }
    
    var displayName: String {
        return firstName ?? username ?? email.components(separatedBy: "@").first ?? "User"
    }
}

// MARK: - Gender Enum
enum Gender: String, Codable, CaseIterable,Sendable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        return rawValue.capitalized
    }
}

// MARK: - Activity Level
enum ActivityLevel: String, Codable, CaseIterable, Sendable {
    case sedentary = "sedentary"
    case lightlyActive = "lightly_active"
    case moderatelyActive = "moderately_active"
    case veryActive = "very_active"
    case extraActive = "extra_active"
    
    var displayName: String {
        switch self {
        case .sedentary: return "Sedentary (little/no exercise)"
        case .lightlyActive: return "Lightly Active (1-3 days/week)"
        case .moderatelyActive: return "Moderately Active (3-5 days/week)"
        case .veryActive: return "Very Active (6-7 days/week)"
        case .extraActive: return "Extra Active (athlete/physical job)"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extraActive: return 1.9
        }
    }
}

// MARK: - Goal Type
enum GoalType: String, Codable, CaseIterable, Sendable {
    case lose = "lose_weight"
    case maintain = "maintain_weight"
    case gain = "gain_weight"
    case muscle = "build_muscle"
    
    var displayName: String {
        switch self {
        case .lose: return "Lose Weight"
        case .maintain: return "Maintain Weight"
        case .gain: return "Gain Weight"
        case .muscle: return "Build Muscle"
        }
    }
}
