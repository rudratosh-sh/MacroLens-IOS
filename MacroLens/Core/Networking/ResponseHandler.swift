//
//  ResponseHandler.swift
//  MacroLens
//
//  Created for: Day 1 - Task 1.4 (Core Architecture Setup)
//  Path: MacroLens/Core/Networking/ResponseHandler.swift
//
//  PURPOSE:
//  Centralized response parsing and error handling for API calls.
//  Decodes API responses, maps HTTP status codes to errors, and provides logging.
//  Separates response handling logic from APIClient for better maintainability.
//
//  DEPENDENCIES:
//  - Foundation (Data, JSONDecoder, HTTPURLResponse)
//  - Config.swift (for logging)
//  - APIClient.swift (APIError, APIResponse)
//  - Constants.swift (error messages)
//
//  USED BY:
//  - APIClient.swift (to parse responses)
//  - NetworkManager.swift (for error handling)
//  - Unit tests (for testing response parsing)
//
//  BENEFITS:
//  - Consistent error mapping across the app
//  - Centralized response logging
//  - Easy to extend with new response types
//  - Better testability
//

import Foundation

// MARK: - Response Handler

/// Handler for processing API responses and mapping errors
final class ResponseHandler {
    
    // MARK: - Singleton
    
    static let shared = ResponseHandler()
    
    // MARK: - Properties
    
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    private init() {
        // Configure JSON decoder
        self.decoder = JSONDecoder()
        
        // Configure date decoding strategy
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        // Handle snake_case to camelCase conversion
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - Response Handling
    
    /// Handle API response and decode to expected type
    /// - Parameters:
    ///   - data: Response data
    ///   - response: HTTP response
    ///   - error: Request error (optional)
    /// - Returns: Decoded data of type T
    /// - Throws: APIError on failure
    func handle<T: Decodable & Sendable>(
        data: Data?,
        response: HTTPURLResponse?,
        error: Error?
    ) async throws -> T {
        
        // Check for network errors first
        if let error = error {
            Config.Logging.log("Network error: \(error.localizedDescription)", level: .error)
            throw APIError.networkError(error)
        }
        
        // Ensure we have a response
        guard let httpResponse = response else {
            Config.Logging.log("No HTTP response received", level: .error)
            throw APIError.invalidResponse
        }
        
        // Log response
        logResponse(httpResponse, data: data)
        
        // Check status code
        try validateStatusCode(httpResponse.statusCode)
        
        // Ensure we have data
        guard let data = data, !data.isEmpty else {
            Config.Logging.log("Empty response data", level: .warning)
            throw APIError.invalidResponse
        }
        
        // Decode response
        return try await decodeResponse(data: data)
    }
    
    /// Handle API response wrapped in APIResponse structure
    /// - Parameters:
    ///   - data: Response data
    ///   - response: HTTP response
    ///   - error: Request error (optional)
    /// - Returns: Decoded data of type T (unwrapped from APIResponse)
    /// - Throws: APIError on failure
    func handleWrapped<T: Decodable & Sendable>(
        data: Data?,
        response: HTTPURLResponse?,
        error: Error?
    ) async throws -> T {
        
        // Check for network errors first
        if let error = error {
            Config.Logging.log("Network error: \(error.localizedDescription)", level: .error)
            throw APIError.networkError(error)
        }
        
        // Ensure we have a response
        guard let httpResponse = response else {
            Config.Logging.log("No HTTP response received", level: .error)
            throw APIError.invalidResponse
        }
        
        // Log response
        logResponse(httpResponse, data: data)
        
        // Check status code
        try validateStatusCode(httpResponse.statusCode)
        
        // Ensure we have data
        guard let data = data, !data.isEmpty else {
            Config.Logging.log("Empty response data", level: .warning)
            throw APIError.invalidResponse
        }
        
        // Decode wrapped response
        let apiResponse: APIResponse<T> = try await decodeResponse(data: data)
        
        // Check success flag
        guard apiResponse.success else {
            let errorMessage = apiResponse.error ?? apiResponse.message ?? Constants.ErrorMessages.genericError
            Config.Logging.log("API returned error: \(errorMessage)", level: .error)
            throw APIError.validationError(errorMessage)
        }
        
        // Unwrap data
        guard let unwrappedData = apiResponse.data else {
            Config.Logging.log("API response missing data", level: .error)
            throw APIError.invalidResponse
        }
        
        return unwrappedData
    }
    
    // MARK: - Decoding
    
    /// Decode response data to expected type
    /// - Parameter data: Response data
    /// - Returns: Decoded data of type T
    /// - Throws: APIError.decodingError on failure
    private func decodeResponse<T: Decodable & Sendable>(data: Data) async throws -> T {
        do {
            let decoded = try decoder.decode(T.self, from: data)
            Config.Logging.log("Successfully decoded response", level: .debug)
            return decoded
        } catch {
            Config.Logging.log("Decoding error: \(error.localizedDescription)", level: .error)
            
            // Log the raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                Config.Logging.log("Raw response: \(jsonString)", level: .debug)
            }
            
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Status Code Validation
    
    /// Validate HTTP status code
    /// - Parameter statusCode: HTTP status code
    /// - Throws: APIError based on status code
    private func validateStatusCode(_ statusCode: Int) throws {
        switch statusCode {
        case 200...299:
            // Success - no error
            return
            
        case 401:
            Config.Logging.log("Unauthorized (401)", level: .error)
            throw APIError.unauthorized
            
        case 403:
            Config.Logging.log("Forbidden (403)", level: .error)
            throw APIError.forbidden
            
        case 404:
            Config.Logging.log("Not Found (404)", level: .error)
            throw APIError.notFound
            
        case 400...499:
            Config.Logging.log("Client error (\(statusCode))", level: .error)
            throw APIError.validationError("Request failed with status code \(statusCode)")
            
        case 500...599:
            Config.Logging.log("Server error (\(statusCode))", level: .error)
            throw APIError.serverError(statusCode)
            
        default:
            Config.Logging.log("Unexpected status code (\(statusCode))", level: .error)
            throw APIError.unknown
        }
    }
    
    // MARK: - Logging
    
    /// Log HTTP response details
    /// - Parameters:
    ///   - response: HTTP response
    ///   - data: Response data (optional)
    private func logResponse(_ response: HTTPURLResponse, data: Data?) {
        let statusCode = response.statusCode
        let url = response.url?.absoluteString ?? "unknown"
        
        var logMessage = "Response: [\(statusCode)] \(url)"
        
        // Add response size
        if let data = data {
            let sizeInKB = Double(data.count) / 1024.0
            logMessage += " - Size: \(String(format: "%.2f", sizeInKB)) KB"
        }
        
        // Determine log level based on status code
        let logLevel: Config.LogLevel = (200...299).contains(statusCode) ? .info : .error
        
        Config.Logging.log(logMessage, level: logLevel)
    }
}

// MARK: - Response Validator

extension ResponseHandler {
    
    /// Validate response structure without decoding
    /// - Parameters:
    ///   - data: Response data
    ///   - response: HTTP response
    /// - Returns: True if response is valid
    func isValidResponse(data: Data?, response: HTTPURLResponse?) -> Bool {
        guard let httpResponse = response else {
            return false
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        
        guard let data = data, !data.isEmpty else {
            return false
        }
        
        return true
    }
    
    /// Extract error message from response data
    /// - Parameter data: Response data
    /// - Returns: Error message string or nil
    func extractErrorMessage(from data: Data?) -> String? {
        guard let data = data else {
            return nil
        }
        
        // Try to decode as APIResponse with Any data
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let error = json["error"] as? String {
                return error
            }
            if let message = json["message"] as? String {
                return message
            }
            if let detail = json["detail"] as? String {
                return detail
            }
        }
        
        return nil
    }
}

// MARK: - Custom Decoder Configuration

extension ResponseHandler {
    
    /// Configure custom date decoding strategy
    /// - Parameter formatter: Custom date formatter
    func setDateDecodingStrategy(_ formatter: DateFormatter) {
        decoder.dateDecodingStrategy = .formatted(formatter)
    }
    
    /// Configure key decoding strategy
    /// - Parameter strategy: Key decoding strategy
    func setKeyDecodingStrategy(_ strategy: JSONDecoder.KeyDecodingStrategy) {
        decoder.keyDecodingStrategy = strategy
    }
}

// MARK: - Error Recovery

extension ResponseHandler {
    
    /// Attempt to recover from decoding error by trying alternative formats
    /// - Parameters:
    ///   - data: Response data
    ///   - originalError: Original decoding error
    /// - Returns: Decoded data or throws error
    /// - Throws: APIError.decodingError if all attempts fail
    func attemptErrorRecovery<T: Decodable & Sendable>(
        data: Data,
        originalError: Error
    ) async throws -> T {
        
        Config.Logging.log("Attempting error recovery for decoding", level: .warning)
        
        // Try with different date strategies
        let alternativeDecoder = JSONDecoder()
        alternativeDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Try ISO8601 date format
        alternativeDecoder.dateDecodingStrategy = .iso8601
        
        do {
            let decoded = try alternativeDecoder.decode(T.self, from: data)
            Config.Logging.log("Error recovery successful with alternative decoder", level: .info)
            return decoded
        } catch {
            Config.Logging.log("Error recovery failed", level: .error)
            throw APIError.decodingError(originalError)
        }
    }
}

// MARK: - Usage Examples

/*
 
 USAGE EXAMPLES:
 
 // Handle standard response
 let user: User = try await ResponseHandler.shared.handle(
     data: data,
     response: httpResponse,
     error: nil
 )
 
 // Handle wrapped API response
 let user: User = try await ResponseHandler.shared.handleWrapped(
     data: data,
     response: httpResponse,
     error: nil
 )
 
 // Validate response before processing
 if ResponseHandler.shared.isValidResponse(data: data, response: httpResponse) {
     // Process response
 }
 
 // Extract error message for user display
 if let errorMessage = ResponseHandler.shared.extractErrorMessage(from: data) {
     // Show error to user
 }
 
 // Custom date format configuration
 let formatter = DateFormatter()
 formatter.dateFormat = "yyyy-MM-dd"
 ResponseHandler.shared.setDateDecodingStrategy(formatter)
 
 */
