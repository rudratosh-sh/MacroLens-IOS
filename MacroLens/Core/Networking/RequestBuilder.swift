//
//  RequestBuilder.swift
//  MacroLens
//
//  Created for: Day 1 - Task 1.4 (Core Architecture Setup)
//  Path: MacroLens/Core/Networking/RequestBuilder.swift
//
//  PURPOSE:
//  Centralized request construction for API calls.
//  Builds URLRequest with proper headers, parameters, encoding, and authentication.
//  Separates request construction logic from APIClient for better testability.
//
//  DEPENDENCIES:
//  - Foundation (URLRequest, URL)
//  - Alamofire (ParameterEncoding)
//  - Config.swift (API configuration, app info)
//  - APIEndpoint.swift (HTTPMethod, endpoint definitions)
//  - KeychainAccess (for token retrieval)
//
//  USED BY:
//  - APIClient.swift (future refactor to use RequestBuilder)
//  - Unit tests (for testing request construction)
//
//  BENEFITS:
//  - Modular and testable request construction
//  - Consistent header management
//  - Flexible parameter encoding
//  - Easy to mock for testing
//

import Foundation
import Alamofire
import UIKit

// MARK: - Request Builder

/// Builder class for constructing URLRequest with proper configuration
final class RequestBuilder {
    
    // MARK: - Properties
    
    private var endpoint: String
    private var method: HTTPMethod
    private var parameters: Parameters?
    private var encoding: ParameterEncoding
    private var headers: [String: String]
    private var queryParameters: [String: String]?
    private var requiresAuth: Bool
    private var timeoutInterval: TimeInterval?
    
    // MARK: - Initialization
    
    /// Initialize RequestBuilder with endpoint and method
    /// - Parameters:
    ///   - endpoint: API endpoint path (e.g., "/auth/login")
    ///   - method: HTTP method (default: .get)
    init(endpoint: String, method: HTTPMethod = .get) {
        self.endpoint = endpoint
        self.method = method
        self.parameters = nil
        self.encoding = JSONEncoding.default
        self.headers = [:]
        self.queryParameters = nil
        self.requiresAuth = true // Default to requiring authentication
        self.timeoutInterval = nil
    }
    
    /// Initialize RequestBuilder with APIEndpoint
    /// - Parameter apiEndpoint: Typed API endpoint
    convenience init(apiEndpoint: APIEndpoint) {
        self.init(endpoint: apiEndpoint.path, method: apiEndpoint.method)
    }
    
    // MARK: - Builder Methods
    
    /// Set request parameters
    /// - Parameter parameters: Dictionary of parameters
    /// - Returns: Self for chaining
    @discardableResult
    func with(parameters: Parameters) -> RequestBuilder {
        self.parameters = parameters
        return self
    }
    
    /// Set query parameters (for GET requests)
    /// - Parameter queryParameters: Dictionary of query parameters
    /// - Returns: Self for chaining
    @discardableResult
    func with(queryParameters: [String: String]) -> RequestBuilder {
        self.queryParameters = queryParameters
        return self
    }
    
    /// Set parameter encoding strategy
    /// - Parameter encoding: Alamofire ParameterEncoding
    /// - Returns: Self for chaining
    @discardableResult
    func with(encoding: ParameterEncoding) -> RequestBuilder {
        self.encoding = encoding
        return self
    }
    
    /// Add custom header
    /// - Parameters:
    ///   - key: Header key
    ///   - value: Header value
    /// - Returns: Self for chaining
    @discardableResult
    func addHeader(key: String, value: String) -> RequestBuilder {
        self.headers[key] = value
        return self
    }
    
    /// Add multiple headers
    /// - Parameter headers: Dictionary of headers
    /// - Returns: Self for chaining
    @discardableResult
    func with(headers: [String: String]) -> RequestBuilder {
        self.headers.merge(headers) { _, new in new }
        return self
    }
    
    /// Set authentication requirement
    /// - Parameter requiresAuth: Whether authentication is required
    /// - Returns: Self for chaining
    @discardableResult
    func requiresAuthentication(_ requiresAuth: Bool) -> RequestBuilder {
        self.requiresAuth = requiresAuth
        return self
    }
    
    /// Set custom timeout interval
    /// - Parameter timeout: Timeout in seconds
    /// - Returns: Self for chaining
    @discardableResult
    func with(timeout: TimeInterval) -> RequestBuilder {
        self.timeoutInterval = timeout
        return self
    }
    
    // MARK: - Build Method
    
    /// Build the URLRequest
    /// - Parameter accessToken: Optional access token for authentication
    /// - Returns: Configured URLRequest
    /// - Throws: RequestBuilderError on failure
    func build(accessToken: String? = nil) throws -> URLRequest {
        
        // Build URL
        guard var url = buildURL() else {
            throw RequestBuilderError.invalidURL(endpoint)
        }
        
        // Append query parameters for GET requests
        if method == .get, let queryParams = queryParameters, !queryParams.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            
            if let urlWithQuery = components?.url {
                url = urlWithQuery
            }
        }
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval ?? Config.API.requestTimeout
        
        // Add default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(Config.App.version, forHTTPHeaderField: "X-App-Version")
        request.setValue(Config.App.build, forHTTPHeaderField: "X-Build-Number")
        request.setValue("iOS", forHTTPHeaderField: "X-Platform")
        request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: "X-OS-Version")
        
        // Add authentication header if required
        if requiresAuth, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Encode parameters
        if let parameters = parameters {
            request = try encoding.encode(request, with: parameters)
        }
        
        Config.Logging.log("Built request: \(method.rawValue) \(url.absoluteString)", level: .debug)
        
        return request
    }
    
    // MARK: - Helper Methods
    
    /// Build full URL from endpoint
    /// - Returns: Complete URL or nil if invalid
    private func buildURL() -> URL? {
        let baseURL = Config.API.fullBaseURL
        let fullPath = endpoint.hasPrefix("/") ? endpoint : "/\(endpoint)"
        return URL(string: baseURL + fullPath)
    }
}

// MARK: - Request Builder Error

enum RequestBuilderError: LocalizedError {
    case invalidURL(String)
    case encodingFailed(Error)
    case missingParameter(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let endpoint):
            return "Invalid URL for endpoint: \(endpoint)"
        case .encodingFailed(let error):
            return "Failed to encode parameters: \(error.localizedDescription)"
        case .missingParameter(let param):
            return "Missing required parameter: \(param)"
        }
    }
}

// MARK: - Convenience Extensions

extension RequestBuilder {
    
    /// Create request builder for GET request
    /// - Parameter endpoint: Endpoint path
    /// - Returns: Configured RequestBuilder
    static func get(_ endpoint: String) -> RequestBuilder {
        return RequestBuilder(endpoint: endpoint, method: .get)
            .with(encoding: URLEncoding.default)
    }
    
    /// Create request builder for POST request
    /// - Parameter endpoint: Endpoint path
    /// - Returns: Configured RequestBuilder
    static func post(_ endpoint: String) -> RequestBuilder {
        return RequestBuilder(endpoint: endpoint, method: .post)
            .with(encoding: JSONEncoding.default)
    }
    
    /// Create request builder for PUT request
    /// - Parameter endpoint: Endpoint path
    /// - Returns: Configured RequestBuilder
    static func put(_ endpoint: String) -> RequestBuilder {
        return RequestBuilder(endpoint: endpoint, method: .put)
            .with(encoding: JSONEncoding.default)
    }
    
    /// Create request builder for PATCH request
    /// - Parameter endpoint: Endpoint path
    /// - Returns: Configured RequestBuilder
    static func patch(_ endpoint: String) -> RequestBuilder {
        return RequestBuilder(endpoint: endpoint, method: .patch)
            .with(encoding: JSONEncoding.default)
    }
    
    /// Create request builder for DELETE request
    /// - Parameter endpoint: Endpoint path
    /// - Returns: Configured RequestBuilder
    static func delete(_ endpoint: String) -> RequestBuilder {
        return RequestBuilder(endpoint: endpoint, method: .delete)
    }
}

// MARK: - Usage Examples

/*
 
 USAGE EXAMPLES:
 
 // Basic GET request
 let request = try RequestBuilder.get("/food/search")
     .with(queryParameters: ["query": "chicken", "limit": "20"])
     .build(accessToken: token)
 
 // POST request with parameters
 let request = try RequestBuilder.post("/auth/login")
     .with(parameters: ["email": "user@example.com", "password": "password"])
     .build(accessToken: nil)
 
 // Using APIEndpoint enum
 let request = try RequestBuilder(apiEndpoint: .auth(.login))
     .with(parameters: loginData)
     .build()
 
 // Custom headers and timeout
 let request = try RequestBuilder.post("/food/scan")
     .with(parameters: imageData)
     .addHeader(key: "X-Custom-Header", value: "value")
     .with(timeout: 60.0)
     .build(accessToken: token)
 
 // Public endpoint (no auth required)
 let request = try RequestBuilder.get("/food/popular")
     .requiresAuthentication(false)
     .build()
 
 */
