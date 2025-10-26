//
//  MockDataGenerator.swift
//  MacroLens
//
//  Path: MacroLens/Testing/MockDataGenerator.swift
//
//  DEPENDENCIES:
//  - User.swift
//  - AuthModels.swift
//  - Food models (when created)
//  - Recipe models (when created)
//
//  USED BY:
//  - Unit tests
//  - UI tests
//  - SwiftUI previews
//  - Development testing
//
//  PURPOSE:
//  - Generate mock data for testing
//  - Provide consistent test fixtures
//  - Support SwiftUI previews
//  - Enable development without backend
//

import Foundation

/// Generator for mock data used in testing and previews
struct MockDataGenerator {
    
    // MARK: - Users
    
    /// Generate mock user
    static func mockUser(
        id: String = "user_123",
        email: String = "test@example.com",
        fullName: String = "John Doe",
        isActive: Bool = true,
        isVerified: Bool = true
    ) -> User {
        return User(
            id: id,
            email: email,
            fullName: fullName,
            isActive: isActive,
            isVerified: isVerified,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            lastLogin: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    /// Generate array of mock users
    static func mockUsers(count: Int = 5) -> [User] {
        return (1...count).map { index in
            mockUser(
                id: "user_\(index)",
                email: "user\(index)@example.com",
                fullName: "User \(index)"
            )
        }
    }
    
    // MARK: - Authentication
    
    /// Generate mock token
    static func mockToken(
        accessToken: String = "mock_access_token_12345",
        refreshToken: String = "mock_refresh_token_67890",
        tokenType: String = "Bearer",
        expiresIn: Int = 3600
    ) -> Token {
        return Token(
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenType: tokenType,
            expiresIn: expiresIn
        )
    }
    
    /// Generate mock auth response
    static func mockAuthResponse(
        user: User? = nil,
        token: Token? = nil
    ) -> AuthResponse {
        return AuthResponse(
            user: user ?? mockUser(),
            tokens: token ?? mockToken()
        )
    }
    
    /// Generate mock login request
    static func mockLoginRequest(
        email: String = "test@example.com",
        password: String = "Password123!"
    ) -> LoginRequest {
        return LoginRequest(
            email: email,
            password: password
        )
    }
    
    /// Generate mock register request
    static func mockRegisterRequest(
        email: String = "newuser@example.com",
        password: String = "Password123!",
        fullName: String = "New User"
    ) -> RegisterRequest {
        return RegisterRequest(
            email: email,
            password: password,
            fullName: fullName
        )
    }
    
    // MARK: - Goals & Activity
    
    /// Generate random goal type
    static func randomGoalType() -> GoalType {
        return GoalType.allCases.randomElement() ?? .maintain
    }
    
    /// Generate random activity level
    static func randomActivityLevel() -> ActivityLevel {
        return ActivityLevel.allCases.randomElement() ?? .moderatelyActive
    }
    
    /// Generate random gender
    static func randomGender() -> Gender {
        return Gender.allCases.randomElement() ?? .preferNotToSay
    }
    
    // MARK: - Food Data (Placeholder - will expand when Food models created)
    
    /// Mock food item
    struct MockFood {
        let id: String
        let name: String
        let brand: String?
        let servingSize: String
        let calories: Int
        let protein: Double
        let carbs: Double
        let fats: Double
    }
    
    /// Generate mock food item
    static func mockFood(
        id: String = "food_123",
        name: String = "Grilled Chicken Breast",
        brand: String? = nil,
        servingSize: String = "100g",
        calories: Int = 165,
        protein: Double = 31.0,
        carbs: Double = 0.0,
        fats: Double = 3.6
    ) -> MockFood {
        return MockFood(
            id: id,
            name: name,
            brand: brand,
            servingSize: servingSize,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fats
        )
    }
    
    /// Generate array of mock foods
    static func mockFoods() -> [MockFood] {
        return [
            mockFood(
                id: "food_1",
                name: "Grilled Chicken Breast",
                servingSize: "100g",
                calories: 165,
                protein: 31.0,
                carbs: 0.0,
                fats: 3.6
            ),
            mockFood(
                id: "food_2",
                name: "Brown Rice",
                servingSize: "1 cup cooked",
                calories: 216,
                protein: 5.0,
                carbs: 45.0,
                fats: 1.8
            ),
            mockFood(
                id: "food_3",
                name: "Broccoli",
                servingSize: "1 cup",
                calories: 55,
                protein: 4.0,
                carbs: 11.0,
                fats: 0.6
            ),
            mockFood(
                id: "food_4",
                name: "Salmon Fillet",
                servingSize: "100g",
                calories: 208,
                protein: 20.0,
                carbs: 0.0,
                fats: 13.0
            ),
            mockFood(
                id: "food_5",
                name: "Greek Yogurt",
                brand: "Chobani",
                servingSize: "1 container (170g)",
                calories: 100,
                protein: 17.0,
                carbs: 6.0,
                fats: 0.0
            ),
            mockFood(
                id: "food_6",
                name: "Oatmeal",
                servingSize: "1 cup cooked",
                calories: 166,
                protein: 6.0,
                carbs: 28.0,
                fats: 3.6
            ),
            mockFood(
                id: "food_7",
                name: "Banana",
                servingSize: "1 medium (118g)",
                calories: 105,
                protein: 1.3,
                carbs: 27.0,
                fats: 0.4
            ),
            mockFood(
                id: "food_8",
                name: "Almonds",
                servingSize: "1 oz (28g)",
                calories: 164,
                protein: 6.0,
                carbs: 6.0,
                fats: 14.0
            )
        ]
    }
    
    // MARK: - Recipe Data (Placeholder)
    
    /// Mock recipe
    struct MockRecipe {
        let id: String
        let name: String
        let description: String
        let cookTime: Int // minutes
        let servings: Int
        let calories: Int
        let protein: Double
        let carbs: Double
        let fats: Double
        let imageURL: String?
    }
    
    /// Generate mock recipe
    static func mockRecipe(
        id: String = "recipe_123",
        name: String = "Chicken & Rice Bowl",
        description: String = "Healthy protein-packed bowl",
        cookTime: Int = 30,
        servings: Int = 2,
        calories: Int = 450,
        protein: Double = 40.0,
        carbs: Double = 45.0,
        fats: Double = 10.0
    ) -> MockRecipe {
        return MockRecipe(
            id: id,
            name: name,
            description: description,
            cookTime: cookTime,
            servings: servings,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fats,
            imageURL: nil
        )
    }
    
    /// Generate array of mock recipes
    static func mockRecipes() -> [MockRecipe] {
        return [
            mockRecipe(
                id: "recipe_1",
                name: "Chicken & Rice Bowl",
                description: "Grilled chicken with brown rice and veggies",
                cookTime: 30,
                servings: 2,
                calories: 450,
                protein: 40.0,
                carbs: 45.0,
                fats: 10.0
            ),
            mockRecipe(
                id: "recipe_2",
                name: "Salmon Salad",
                description: "Fresh salmon with mixed greens",
                cookTime: 20,
                servings: 1,
                calories: 380,
                protein: 35.0,
                carbs: 15.0,
                fats: 20.0
            ),
            mockRecipe(
                id: "recipe_3",
                name: "Protein Smoothie",
                description: "Banana, protein powder, and almond milk",
                cookTime: 5,
                servings: 1,
                calories: 300,
                protein: 30.0,
                carbs: 35.0,
                fats: 8.0
            )
        ]
    }
    
    // MARK: - Progress Data
    
    /// Mock weight entry
    struct MockWeightEntry {
        let date: Date
        let weight: Double // in kg
    }
    
    /// Generate mock weight history
    static func mockWeightHistory(days: Int = 30) -> [MockWeightEntry] {
        let startWeight = 80.0
        let endWeight = 75.0
        let weightLossPerDay = (startWeight - endWeight) / Double(days)
        
        return (0..<days).map { day in
            let date = Calendar.current.date(byAdding: .day, value: -days + day, to: Date())!
            let weight = startWeight - (weightLossPerDay * Double(day)) + Double.random(in: -0.3...0.3)
            return MockWeightEntry(date: date, weight: weight)
        }
    }
    
    // MARK: - Meal Log Data
    
    /// Mock meal type
    enum MockMealType: String, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
    
    /// Mock food log entry
    struct MockFoodLog {
        let id: String
        let food: MockFood
        let mealType: MockMealType
        let servings: Double
        let loggedAt: Date
    }
    
    /// Generate mock food logs for today
    static func mockTodayFoodLogs() -> [MockFoodLog] {
        let foods = mockFoods()
        let now = Date()
        
        return [
            MockFoodLog(
                id: "log_1",
                food: foods[6], // Banana
                mealType: .breakfast,
                servings: 1.0,
                loggedAt: Calendar.current.date(byAdding: .hour, value: -6, to: now)!
            ),
            MockFoodLog(
                id: "log_2",
                food: foods[5], // Oatmeal
                mealType: .breakfast,
                servings: 1.0,
                loggedAt: Calendar.current.date(byAdding: .hour, value: -6, to: now)!
            ),
            MockFoodLog(
                id: "log_3",
                food: foods[0], // Chicken
                mealType: .lunch,
                servings: 1.5,
                loggedAt: Calendar.current.date(byAdding: .hour, value: -3, to: now)!
            ),
            MockFoodLog(
                id: "log_4",
                food: foods[1], // Rice
                mealType: .lunch,
                servings: 1.0,
                loggedAt: Calendar.current.date(byAdding: .hour, value: -3, to: now)!
            )
        ]
    }
    
    // MARK: - Nutrition Summary
    
    /// Mock daily nutrition summary
    struct MockNutritionSummary {
        let calories: Int
        let protein: Double
        let carbs: Double
        let fats: Double
        let calorieGoal: Int
        let proteinGoal: Double
        let carbsGoal: Double
        let fatsGoal: Double
    }
    
    /// Generate mock nutrition summary
    static func mockNutritionSummary() -> MockNutritionSummary {
        return MockNutritionSummary(
            calories: 1450,
            protein: 120.0,
            carbs: 150.0,
            fats: 45.0,
            calorieGoal: 2000,
            proteinGoal: 150.0,
            carbsGoal: 200.0,
            fatsGoal: 65.0
        )
    }
    
    // MARK: - Helper Methods
    
    /// Generate random date within last N days
    static func randomDate(daysAgo: Int = 30) -> Date {
        let days = Int.random(in: 0...daysAgo)
        return Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }
    
    /// Generate random time today
    static func randomTimeToday() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let hour = Int.random(in: 6...22)
        let minute = Int.random(in: 0...59)
        
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now)!
    }
}

// MARK: - Usage Examples

/*
 
 // MARK: - In Tests
 
 func testUserCreation() {
     let user = MockDataGenerator.mockUser()
     XCTAssertEqual(user.email, "test@example.com")
 }
 
 func testAuthResponse() {
     let response = MockDataGenerator.mockAuthResponse()
     XCTAssertNotNil(response.tokens.accessToken)
 }
 
 
 // MARK: - In SwiftUI Previews
 
 struct ProfileView_Previews: PreviewProvider {
     static var previews: some View {
         ProfileView(user: MockDataGenerator.mockUser())
     }
 }
 
 struct FoodListView_Previews: PreviewProvider {
     static var previews: some View {
         FoodListView(foods: MockDataGenerator.mockFoods())
     }
 }
 
 
 // MARK: - In ViewModels (Development)
 
 class DashboardViewModel: ObservableObject {
     @Published var nutritionSummary: MockDataGenerator.MockNutritionSummary
     
     init() {
         #if DEBUG
         self.nutritionSummary = MockDataGenerator.mockNutritionSummary()
         #endif
     }
 }
 
 */
