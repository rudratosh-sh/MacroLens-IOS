//
//  APIEndpoint.swift
//  MacroLens
//
//  Created for: Day 1 - Task 1.4 (Core Architecture Setup)
//  Path: MacroLens/Core/Networking/APIEndpoint.swift
//
//  PURPOSE:
//  Type-safe API endpoint definitions replacing string-based endpoints.
//  Provides compile-time safety, prevents typos, and enables better IDE autocomplete.
//
//  DEPENDENCIES:
//  - Config.swift (for base URL)
//  - None (self-contained enum)
//
//  USED BY:
//  - APIClient.swift (to construct URLs)
//  - NetworkManager.swift (for API requests)
//  - All service classes (AuthService, FoodService, etc.)
//
//  MIGRATION:
//  Replace Config.Endpoints.register with APIEndpoint.auth(.register).path
//  Or use APIEndpoint.auth(.register).fullURL for complete URL
//

import Foundation

/// Type-safe API endpoint definitions
/// Organized by feature/domain for better maintainability
enum APIEndpoint {
    
    // MARK: - Authentication
    case auth(AuthEndpoint)
    
    // MARK: - Users
    case users(UserEndpoint)
    
    // MARK: - Food
    case food(FoodEndpoint)
    
    // MARK: - Food Logs
    case foodLogs(FoodLogEndpoint)
    
    // MARK: - Nutrition
    case nutrition(NutritionEndpoint)
    
    // MARK: - Recipes
    case recipes(RecipeEndpoint)
    
    // MARK: - Meal Plans
    case mealPlans(MealPlanEndpoint)
    
    // MARK: - Progress
    case progress(ProgressEndpoint)
    
    // MARK: - Health
    case health(HealthEndpoint)
    
    // MARK: - Path Generation
    
    /// Returns the endpoint path (without base URL)
    var path: String {
        switch self {
        case .auth(let endpoint):
            return endpoint.path
        case .users(let endpoint):
            return endpoint.path
        case .food(let endpoint):
            return endpoint.path
        case .foodLogs(let endpoint):
            return endpoint.path
        case .nutrition(let endpoint):
            return endpoint.path
        case .recipes(let endpoint):
            return endpoint.path
        case .mealPlans(let endpoint):
            return endpoint.path
        case .progress(let endpoint):
            return endpoint.path
        case .health(let endpoint):
            return endpoint.path
        }
    }
    
    /// Returns the full URL including base URL
    var fullURL: String {
        return Config.API.fullBaseURL + path
    }
    
    /// HTTP method for this endpoint
    var method: HTTPMethod {
        switch self {
        case .auth(let endpoint):
            return endpoint.method
        case .users(let endpoint):
            return endpoint.method
        case .food(let endpoint):
            return endpoint.method
        case .foodLogs(let endpoint):
            return endpoint.method
        case .nutrition(let endpoint):
            return endpoint.method
        case .recipes(let endpoint):
            return endpoint.method
        case .mealPlans(let endpoint):
            return endpoint.method
        case .progress(let endpoint):
            return endpoint.method
        case .health(let endpoint):
            return endpoint.method
        }
    }
}

// MARK: - Authentication Endpoints

extension APIEndpoint {
    enum AuthEndpoint {
        case register
        case login
        case refreshToken
        case logout
        case verifyEmail
        case resetPassword
        case me // Get current user
        
        var path: String {
            switch self {
            case .register:
                return "/auth/register"
            case .login:
                return "/auth/login"
            case .refreshToken:
                return "/auth/refresh"
            case .logout:
                return "/auth/logout"
            case .verifyEmail:
                return "/auth/verify-email"
            case .resetPassword:
                return "/auth/reset-password"
            case .me:
                return "/auth/me"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .register, .login, .refreshToken, .logout, .verifyEmail, .resetPassword:
                return .post
            case .me:
                return .get
            }
        }
    }
}

// MARK: - User Endpoints

extension APIEndpoint {
    enum UserEndpoint {
        case profile
        case updateProfile
        case deleteAccount
        case preferences
        case updatePreferences
        
        var path: String {
            switch self {
            case .profile:
                return "/users/profile"
            case .updateProfile:
                return "/users/profile"
            case .deleteAccount:
                return "/users/account"
            case .preferences:
                return "/users/preferences"
            case .updatePreferences:
                return "/users/preferences"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .profile, .preferences:
                return .get
            case .updateProfile, .updatePreferences:
                return .put
            case .deleteAccount:
                return .delete
            }
        }
    }
}

// MARK: - Food Endpoints

extension APIEndpoint {
    enum FoodEndpoint {
        case search
        case details(String) // food_id
        case scan
        case custom
        case popular
        
        var path: String {
            switch self {
            case .search:
                return "/food/search"
            case .details(let foodId):
                return "/food/\(foodId)"
            case .scan:
                return "/food/scan"
            case .custom:
                return "/food/custom"
            case .popular:
                return "/food/popular"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .search, .details, .popular:
                return .get
            case .scan, .custom:
                return .post
            }
        }
    }
}

// MARK: - Food Log Endpoints

extension APIEndpoint {
    enum FoodLogEndpoint {
        case list
        case create
        case details(String) // log_id
        case update(String) // log_id
        case delete(String) // log_id
        case today
        case byDate(String) // date (YYYY-MM-DD)
        case dailySummary
        
        var path: String {
            switch self {
            case .list:
                return "/food/logs"
            case .create:
                return "/food/log"
            case .details(let logId):
                return "/food/logs/\(logId)"
            case .update(let logId):
                return "/food/logs/\(logId)"
            case .delete(let logId):
                return "/food/logs/\(logId)"
            case .today:
                return "/food/logs/today"
            case .byDate(let date):
                return "/food/logs/date/\(date)"
            case .dailySummary:
                return "/food/logs/daily-summary"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .list, .details, .today, .byDate, .dailySummary:
                return .get
            case .create:
                return .post
            case .update:
                return .put
            case .delete:
                return .delete
            }
        }
    }
}

// MARK: - Nutrition Endpoints

extension APIEndpoint {
    enum NutritionEndpoint {
        case goals
        case updateGoals
        case daily
        case macroBreakdown
        
        var path: String {
            switch self {
            case .goals:
                return "/nutrition/goals"
            case .updateGoals:
                return "/nutrition/goals"
            case .daily:
                return "/nutrition/daily"
            case .macroBreakdown:
                return "/nutrition/macros"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .goals, .daily, .macroBreakdown:
                return .get
            case .updateGoals:
                return .put
            }
        }
    }
}

// MARK: - Recipe Endpoints

extension APIEndpoint {
    enum RecipeEndpoint {
        case list
        case search
        case details(String) // recipe_id
        case create
        case update(String) // recipe_id
        case delete(String) // recipe_id
        case favorites
        case toggleFavorite(String) // recipe_id
        
        var path: String {
            switch self {
            case .list:
                return "/recipes"
            case .search:
                return "/recipes/search"
            case .details(let recipeId):
                return "/recipes/\(recipeId)"
            case .create:
                return "/recipes"
            case .update(let recipeId):
                return "/recipes/\(recipeId)"
            case .delete(let recipeId):
                return "/recipes/\(recipeId)"
            case .favorites:
                return "/recipes/favorites"
            case .toggleFavorite(let recipeId):
                return "/recipes/\(recipeId)/favorite"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .list, .search, .details, .favorites:
                return .get
            case .create, .toggleFavorite:
                return .post
            case .update:
                return .put
            case .delete:
                return .delete
            }
        }
    }
}

// MARK: - Meal Plan Endpoints

extension APIEndpoint {
    enum MealPlanEndpoint {
        case list
        case generate
        case details(String) // plan_id
        case update(String) // plan_id
        case delete(String) // plan_id
        case active
        
        var path: String {
            switch self {
            case .list:
                return "/meal-plans"
            case .generate:
                return "/meal-plans/generate"
            case .details(let planId):
                return "/meal-plans/\(planId)"
            case .update(let planId):
                return "/meal-plans/\(planId)"
            case .delete(let planId):
                return "/meal-plans/\(planId)"
            case .active:
                return "/meal-plans/active"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .list, .details, .active:
                return .get
            case .generate:
                return .post
            case .update:
                return .put
            case .delete:
                return .delete
            }
        }
    }
}

// MARK: - Progress Endpoints

extension APIEndpoint {
    enum ProgressEndpoint {
        case list
        case create
        case history
        case stats
        
        var path: String {
            switch self {
            case .list:
                return "/progress"
            case .create:
                return "/progress"
            case .history:
                return "/progress/history"
            case .stats:
                return "/progress/stats"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .list, .history, .stats:
                return .get
            case .create:
                return .post
            }
        }
    }
}

// MARK: - Health Integration Endpoints

extension APIEndpoint {
    enum HealthEndpoint {
        case sync
        case data
        
        var path: String {
            switch self {
            case .sync:
                return "/health/sync"
            case .data:
                return "/health/data"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .sync:
                return .post
            case .data:
                return .get
            }
        }
    }
}

// MARK: - HTTPMethod enum (if not already defined in APIClient)

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
