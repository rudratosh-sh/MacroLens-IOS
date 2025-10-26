//
//  ProfileSetupViewModel.swift
//  MacroLens
//
//  Path: MacroLens/ViewModels/ProfileSetupViewModel.swift
//
//  DEPENDENCIES:
//  - ProfileSetupModels.swift
//  - NetworkManager.swift
//  - AuthService.swift
//
//  USED BY:
//  - BasicInfoView
//  - ActivityLevelView
//  - GoalsView
//  - DietaryPreferencesView
//
//  PURPOSE:
//  - Manage state for 4-step profile setup flow
//  - Validate input at each step
//  - Submit profile data to backend API
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileSetupViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Step 1: Basic Info
    @Published var age: Int = 25
    @Published var gender: Gender = .male
    @Published var heightCm: Double = 170
    @Published var weightKg: Double = 70
    @Published var usesMetric: Bool = true
    
    // Step 2: Activity Level
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    
    // Step 3: Goals
    @Published var goal: GoalType = .maintain
    @Published var targetWeightKg: Double?
    
    // Step 4: Dietary Preferences
    @Published var dietaryRestrictions: Set<DietaryRestriction> = []
    @Published var allergies: Set<Allergy> = []
    
    // Navigation & UI State
    @Published var currentStep: Int = 1
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccess: Bool = false
    
    // Validation Errors
    @Published var ageError: String?
    @Published var heightError: String?
    @Published var weightError: String?
    @Published var targetWeightError: String?
    
    // Calculated Values
    @Published var calculatedProfile: UserProfile?
    
    // MARK: - Private Properties
    
    private let authService = AuthService.shared
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Step 1: Basic Info Validation
    
    func validateBasicInfo() -> Bool {
        var isValid = true
        
        // Age validation
        if !ProfileValidation.validateAge(age) {
            ageError = "Age must be between 13 and 120"
            isValid = false
        } else {
            ageError = nil
        }
        
        // Height validation
        if !ProfileValidation.validateHeight(heightCm) {
            heightError = "Height must be between 100cm and 250cm"
            isValid = false
        } else {
            heightError = nil
        }
        
        // Weight validation
        if !ProfileValidation.validateWeight(weightKg) {
            weightError = "Weight must be between 30kg and 300kg"
            isValid = false
        } else {
            weightError = nil
        }
        
        return isValid
    }
    
    // MARK: - Step 2: Activity Level (No validation needed)
    
    func validateActivityLevel() -> Bool {
        return true // Activity level is always valid (enum selection)
    }
    
    // MARK: - Step 3: Goals Validation
    
    func validateGoals() -> Bool {
        // Validate target weight if goal requires it
        if goal == .loseWeight || goal == .gainMuscle {
            guard let target = targetWeightKg else {
                targetWeightError = "Please set a target weight"
                return false
            }
            
            if !ProfileValidation.validateTargetWeight(weightKg, target, goal: goal) {
                if goal == .loseWeight {
                    targetWeightError = "Target weight must be less than current weight"
                } else {
                    targetWeightError = "Target weight must be more than current weight"
                }
                return false
            }
        }
        
        targetWeightError = nil
        return true
    }
    
    // MARK: - Step 4: Dietary Preferences (No validation needed)
    
    func validatePreferences() -> Bool {
        return true // Preferences are optional
    }
    
    // MARK: - Navigation
    
    func nextStep() {
        let isValid: Bool
        
        switch currentStep {
        case 1:
            isValid = validateBasicInfo()
        case 2:
            isValid = validateActivityLevel()
        case 3:
            isValid = validateGoals()
        case 4:
            isValid = validatePreferences()
        default:
            isValid = false
        }
        
        if isValid {
            if currentStep < 4 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep += 1
                }
            } else {
                // Final step - submit profile
                Task {
                    await submitProfile()
                }
            }
        }
    }
    
    func previousStep() {
        if currentStep > 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }
    
    // MARK: - Unit Conversion Helpers
    
    func heightInFeet() -> Int {
        let totalInches = heightCm / 2.54
        return Int(totalInches / 12)
    }
    
    func heightInInches() -> Int {
        let totalInches = heightCm / 2.54
        return Int(totalInches.truncatingRemainder(dividingBy: 12))
    }
    
    func setHeightFromImperial(feet: Int, inches: Int) {
        let totalInches = Double(feet * 12 + inches)
        heightCm = totalInches * 2.54
    }
    
    func weightInLbs() -> Double {
        return weightKg * 2.20462
    }
    
    func setWeightFromLbs(_ lbs: Double) {
        weightKg = lbs / 2.20462
    }
    
    func targetWeightInLbs() -> Double? {
        guard let target = targetWeightKg else { return nil }
        return target * 2.20462
    }
    
    func setTargetWeightFromLbs(_ lbs: Double) {
        targetWeightKg = lbs / 2.20462
    }
    
    // MARK: - API Submission
    
    func submitProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create profile request
            let profileRequest = ProfileSetupRequest(
                age: age,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                targetWeightKg: targetWeightKg,
                activityLevel: activityLevel,
                goal: goal
            )
            
            // Submit profile to backend
            let profileRequestDict = try profileRequest.toDictionary()
            let response: ProfileResponse = try await networkManager.put(
                endpoint: APIEndpoint.users(.updateProfile).fullURL,
                parameters: profileRequestDict
            )
            
            // Store calculated profile
            calculatedProfile = response.data.profile
            
            // Submit preferences if any selected
            if !dietaryRestrictions.isEmpty || !allergies.isEmpty {
                try await submitPreferences()
            }
            
            // Success
            Config.Logging.log("Profile setup completed successfully", level: .info)
            
            withAnimation {
                showSuccess = true
            }
            
            // Navigate to home after 2 seconds
            try await Task.sleep(nanoseconds: 2_000_000_000)
            // Navigation will be handled by parent view
            
        } catch {
            errorMessage = networkManager.friendlyErrorMessage(error)
            Config.Logging.log("Profile setup failed: \(error)", level: .error)
        }
        
        isLoading = false
    }
    
    private func submitPreferences() async throws {
        let preferencesRequest = PreferencesSetupRequest(
            dietaryRestrictions: Array(dietaryRestrictions),
            allergies: Array(allergies),
            dislikedFoods: nil,
            favoriteFoods: nil,
            cuisinePreferences: nil,
            mealPrepTime: nil,
            cookingSkill: nil,
            budgetPerMeal: nil,
            notificationsEnabled: true,
            emailNotifications: false,
            reminderTimes: ["08:00", "12:00", "18:00"]
        )
        
        let preferencesRequestDict = try preferencesRequest.toDictionary()
        let _: PreferencesResponse = try await networkManager.put(
            endpoint: APIEndpoint.users(.updatePreferences).fullURL,
            parameters: preferencesRequestDict
        )
        
        Config.Logging.log("Preferences updated successfully", level: .info)
    }
    
    // MARK: - Helpers
    
    func progressPercentage() -> Double {
        return Double(currentStep) / 4.0
    }
    
    func canProceed() -> Bool {
        switch currentStep {
        case 1:
            return validateBasicInfo()
        case 2:
            return validateActivityLevel()
        case 3:
            return validateGoals()
        case 4:
            return validatePreferences()
        default:
            return false
        }
    }
}

// MARK: - Codable to Dictionary Extension

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert to dictionary"])
        }
        return dictionary
    }
}
