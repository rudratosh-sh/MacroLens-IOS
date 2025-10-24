//
//  User.swift
//  MacroLens
//
//  Path: MacroLens/Models/User.swift
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable, Sendable {
    let id: String
    let email: String
    let fullName: String
    let isActive: Bool
    let isVerified: Bool
    let createdAt: String
    let lastLogin: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case isActive = "is_active"
        case isVerified = "is_verified"
        case createdAt = "created_at"
        case lastLogin = "last_login"
    }
}

// MARK: - Gender
enum Gender: String, Codable, CaseIterable, Sendable {
    case male, female, other
    case preferNotToSay = "prefer_not_to_say"
}

// MARK: - Activity Level
enum ActivityLevel: String, Codable, CaseIterable, Sendable {
    case sedentary
    case lightlyActive = "lightly_active"
    case moderatelyActive = "moderately_active"
    case veryActive = "very_active"
    case extraActive = "extra_active"
}

// MARK: - Goal Type
enum GoalType: String, Codable, CaseIterable, Sendable {
    case loseWeight = "lose_weight"
    case maintainWeight = "maintain_weight"
    case gainWeight = "gain_weight"
    case buildMuscle = "build_muscle"
}
