//
//  ValidationHelper.swift
//  MacroLens
//
//  Input validation utilities
//

import Foundation

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
        
        return .valid
    }
    
    /// Check if passwords match
    /// - Parameters:
    ///   - password: Original password
    ///   - confirmPassword: Confirmation password
    /// - Returns: ValidationResult with status and error message
    static func validatePasswordMatch(_ password: String, _ confirmPassword: String) -> ValidationResult {
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
