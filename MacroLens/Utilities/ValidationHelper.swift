//
//  ValidationHelper.swift
//  MacroLens
//
//  Path: MacroLens/Utilities/ValidationHelper.swift
//
//  Input validation utilities
//

import Foundation
import SwiftUI

// MARK: - Validation Result
struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
    
    static var valid: ValidationResult {
        ValidationResult(isValid: true, errorMessage: nil)
    }
    
    static func invalid(_ message: String) -> ValidationResult {
        ValidationResult(isValid: false, errorMessage: message)
    }
}

// MARK: - Password Strength
enum PasswordStrength {
    case weak
    case medium
    case strong
    
    var color: Color {
        switch self {
        case .weak:
            return .error
        case .medium:
            return .orange
        case .strong:
            return .success
        }
    }
    
    var text: String {
        switch self {
        case .weak:
            return "Weak"
        case .medium:
            return "Medium"
        case .strong:
            return "Strong"
        }
    }
    
    var progress: Double {
        switch self {
        case .weak:
            return 0.33
        case .medium:
            return 0.66
        case .strong:
            return 1.0
        }
    }
}

// MARK: - Validation Helper
struct ValidationHelper {
    
    // MARK: - Email Validation
    
    /// Validate email format
    /// - Parameter email: Email string to validate
    /// - Returns: ValidationResult with status and error message
    static func validateEmail(_ email: String) -> ValidationResult {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty else {
            return .invalid("Email is required")
        }
        
        let emailRegex = Constants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: trimmedEmail) else {
            return .invalid("Please enter a valid email address")
        }
        
        return .valid
    }
    
    // MARK: - Password Validation
    
    /// Validate password strength
    /// - Parameter password: Password string to validate
    /// - Returns: ValidationResult with status and error message
    static func validatePassword(_ password: String) -> ValidationResult {
        guard !password.isEmpty else {
            return .invalid("Password is required")
        }
        
        guard password.count >= Constants.Validation.minPasswordLength else {
            return .invalid("Password must be at least \(Constants.Validation.minPasswordLength) characters")
        }
        
        guard password.count <= Constants.Validation.maxPasswordLength else {
            return .invalid("Password must be less than \(Constants.Validation.maxPasswordLength) characters")
        }
        
        // Check for at least one uppercase letter
        let uppercaseRegex = ".*[A-Z]+.*"
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        guard uppercasePredicate.evaluate(with: password) else {
            return .invalid("Password must contain at least one uppercase letter")
        }
        
        // Check for at least one lowercase letter
        let lowercaseRegex = ".*[a-z]+.*"
        let lowercasePredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex)
        guard lowercasePredicate.evaluate(with: password) else {
            return .invalid("Password must contain at least one lowercase letter")
        }
        
        // Check for at least one number
        let numberRegex = ".*[0-9]+.*"
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        guard numberPredicate.evaluate(with: password) else {
            return .invalid("Password must contain at least one number")
        }
        
        // Check for at least one special character
        let specialCharRegex = ".*[!@#$%^&*(),.?\":{}|<>]+.*"
        let specialCharPredicate = NSPredicate(format: "SELF MATCHES %@", specialCharRegex)
        guard specialCharPredicate.evaluate(with: password) else {
            return .invalid("Password must contain at least one special character")
        }
        
        return .valid
    }
    
    /// Get password strength level
    /// - Parameter password: Password to evaluate
    /// - Returns: PasswordStrength enum value
    static func getPasswordStrength(_ password: String) -> PasswordStrength {
        if password.isEmpty {
            return .weak
        }
        
        var score = 0
        
        // Length check (20%)
        if password.count >= 8 {
            score += 1
        }
        if password.count >= 12 {
            score += 1
        }
        
        // Uppercase letter (20%)
        if password.range(of: "[A-Z]", options: .regularExpression) != nil {
            score += 1
        }
        
        // Lowercase letter (20%)
        if password.range(of: "[a-z]", options: .regularExpression) != nil {
            score += 1
        }
        
        // Number (20%)
        if password.range(of: "[0-9]", options: .regularExpression) != nil {
            score += 1
        }
        
        // Special character (20%)
        if password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil {
            score += 1
        }
        
        // Calculate strength
        switch score {
        case 0...2:
            return .weak
        case 3...4:
            return .medium
        case 5...6:
            return .strong
        default:
            return .strong
        }
    }
    
    /// Check if passwords match
    /// - Parameters:
    ///   - password: Original password
    ///   - confirmPassword: Confirmation password
    /// - Returns: ValidationResult with status and error message
    static func validatePasswordMatch(_ password: String, _ confirmPassword: String) -> ValidationResult {
        guard !confirmPassword.isEmpty else {
            return .invalid("Please confirm your password")
        }
        
        guard password == confirmPassword else {
            return .invalid("Passwords do not match")
        }
        
        return .valid
    }
    
    // MARK: - Name Validation
    
    /// Validate name (first name, last name, username)
    /// - Parameters:
    ///   - name: Name string to validate
    ///   - fieldName: Name of the field for error messages
    /// - Returns: ValidationResult with status and error message
    static func validateName(_ name: String, fieldName: String = "Name") -> ValidationResult {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            return .invalid("\(fieldName) is required")
        }
        
        guard trimmedName.count >= Constants.Validation.minUsernameLength else {
            return .invalid("\(fieldName) must be at least \(Constants.Validation.minUsernameLength) characters")
        }
        
        guard trimmedName.count <= Constants.Validation.maxUsernameLength else {
            return .invalid("\(fieldName) must be less than \(Constants.Validation.maxUsernameLength) characters")
        }
        
        return .valid
    }
    
    /// Validate full name (first + last name)
    /// - Parameter fullName: Full name string to validate
    /// - Returns: ValidationResult with validation status
    static func validateFullName(_ fullName: String) -> ValidationResult {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if empty
        guard !trimmed.isEmpty else {
            return .invalid("Full name is required")
        }
        
        // Check minimum length (at least 2 characters)
        guard trimmed.count >= 2 else {
            return .invalid("Name must be at least 2 characters")
        }
        
        // Check maximum length
        guard trimmed.count <= 100 else {
            return .invalid("Name must be less than 100 characters")
        }
        
        // Check for valid characters (letters, spaces, hyphens, apostrophes)
        let namePattern = "^[a-zA-Z\\s'-]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", namePattern)
        
        guard namePredicate.evaluate(with: trimmed) else {
            return .invalid("Name can only contain letters, spaces, hyphens, and apostrophes")
        }
        
        // Check that name has at least two parts (first and last name)
        let nameParts = trimmed.components(separatedBy: " ").filter { !$0.isEmpty }
        guard nameParts.count >= 2 else {
            return .invalid("Please enter your full name (first and last name)")
        }
        
        // Check that each part is at least 2 characters
        for part in nameParts {
            guard part.count >= 2 else {
                return .invalid("Each part of your name must be at least 2 characters")
            }
        }
        
        return .valid
    }
    
    // MARK: - Number Validation
    
    /// Validate numeric input
    /// - Parameters:
    ///   - value: String value to validate
    ///   - min: Minimum allowed value
    ///   - max: Maximum allowed value
    ///   - fieldName: Name of the field for error messages
    /// - Returns: ValidationResult with status and error message
    static func validateNumber(
        _ value: String,
        min: Double? = nil,
        max: Double? = nil,
        fieldName: String = "Value"
    ) -> ValidationResult {
        guard !value.isEmpty else {
            return .invalid("\(fieldName) is required")
        }
        
        guard let number = Double(value) else {
            return .invalid("Please enter a valid number")
        }
        
        if let min = min, number < min {
            return .invalid("\(fieldName) must be at least \(min)")
        }
        
        if let max = max, number > max {
            return .invalid("\(fieldName) must be less than \(max)")
        }
        
        return .valid
    }
    
    /// Validate integer input
    /// - Parameters:
    ///   - value: String value to validate
    ///   - min: Minimum allowed value
    ///   - max: Maximum allowed value
    ///   - fieldName: Name of the field for error messages
    /// - Returns: ValidationResult with status and error message
    static func validateInteger(
        _ value: String,
        min: Int? = nil,
        max: Int? = nil,
        fieldName: String = "Value"
    ) -> ValidationResult {
        guard !value.isEmpty else {
            return .invalid("\(fieldName) is required")
        }
        
        guard let number = Int(value) else {
            return .invalid("Please enter a valid whole number")
        }
        
        if let min = min, number < min {
            return .invalid("\(fieldName) must be at least \(min)")
        }
        
        if let max = max, number > max {
            return .invalid("\(fieldName) must be less than \(max)")
        }
        
        return .valid
    }
    
    // MARK: - Nutrition Validation
    
    /// Validate calorie input
    /// - Parameter calories: Calorie string to validate
    /// - Returns: ValidationResult with status and error message
    static func validateCalories(_ calories: String) -> ValidationResult {
        return validateNumber(
            calories,
            min: Constants.Nutrition.minDailyCalories,
            max: Constants.Nutrition.maxDailyCalories,
            fieldName: "Calories"
        )
    }
    
    /// Validate protein input
    /// - Parameter protein: Protein grams string to validate
    /// - Returns: ValidationResult with status and error message
    static func validateProtein(_ protein: String) -> ValidationResult {
        return validateNumber(
            protein,
            min: Constants.Nutrition.minProteinGrams,
            max: Constants.Nutrition.maxProteinGrams,
            fieldName: "Protein"
        )
    }
    
    /// Validate macro ratio (percentage)
    /// - Parameter ratio: Ratio string to validate
    /// - Returns: ValidationResult with status and error message
    static func validateMacroRatio(_ ratio: String) -> ValidationResult {
        return validateNumber(
            ratio,
            min: 0,
            max: 100,
            fieldName: "Macro ratio"
        )
    }
    
    /// Validate that macro ratios sum to 100%
    /// - Parameters:
    ///   - protein: Protein percentage
    ///   - carbs: Carbs percentage
    ///   - fats: Fats percentage
    /// - Returns: ValidationResult with status and error message
    static func validateMacroRatioSum(
        protein: Double,
        carbs: Double,
        fats: Double
    ) -> ValidationResult {
        let sum = protein + carbs + fats
        let tolerance = 0.01 // Allow small floating point errors
        
        guard abs(sum - 100.0) < tolerance else {
            return .invalid("Macro ratios must sum to 100% (currently \(String(format: "%.1f", sum))%)")
        }
        
        return .valid
    }
    
    // MARK: - Weight Validation
    
    /// Validate weight input
    /// - Parameter weight: Weight string to validate
    /// - Returns: ValidationResult with status and error message
    static func validateWeight(_ weight: String) -> ValidationResult {
        return validateNumber(
            weight,
            min: 20,
            max: 500,
            fieldName: "Weight"
        )
    }
    
    /// Validate height input (in cm)
    /// - Parameter height: Height string to validate
    /// - Returns: ValidationResult with status and error message
    static func validateHeight(_ height: String) -> ValidationResult {
        return validateNumber(
            height,
            min: 100,
            max: 300,
            fieldName: "Height"
        )
    }
    
    /// Validate age input
    /// - Parameter age: Age string to validate
    /// - Returns: ValidationResult with status and error message
    static func validateAge(_ age: String) -> ValidationResult {
        return validateInteger(
            age,
            min: 13,
            max: 120,
            fieldName: "Age"
        )
    }
    
    // MARK: - Generic Required Field
    
    /// Validate that a field is not empty
    /// - Parameters:
    ///   - value: Value to validate
    ///   - fieldName: Name of the field for error messages
    /// - Returns: ValidationResult with status and error message
    static func validateRequired(_ value: String, fieldName: String = "Field") -> ValidationResult {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            return .invalid("\(fieldName) is required")
        }
        return .valid
    }
}
