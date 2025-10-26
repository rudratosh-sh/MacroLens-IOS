//
//  User.swift
//  MacroLens
//
//  Path: MacroLens/Models/User.swift
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable, Sendable, Equatable {
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
 
