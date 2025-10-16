//
//  NetworkManager.swift
//  MacroLens
//
//  High-level networking service using APIClient
//

import Foundation
import Combine

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = NetworkManager()
    
    // MARK: - Properties
    @Published var isOnline: Bool = true
    @Published var isLoading: Bool = false
    
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        setupNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    private func setupNetworkMonitoring() {
        // TODO: Implement proper network reachability monitoring in Day 2
        // For now, assume online
        isOnline = true
    }
    
    // MARK: - Generic Request Methods
    
    /// Perform GET request
    func get<T: Decodable & Sendable>(
        endpoint: String,
        parameters: [String: Any]? = nil
    ) async throws -> T {
        guard isOnline else {
            throw APIError.networkError(NSError(domain: "NetworkManager", code: -1009, userInfo: nil))
        }
        
        await MainActor.run { self.isLoading = true }
        defer {
            Task { @MainActor in self.isLoading = false }
        }
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .get,
            parameters: parameters
        )
    }
    
    /// Perform POST request
    func post<T: Decodable & Sendable>(
        endpoint: String,
        parameters: [String: Any]
    ) async throws -> T {
        guard isOnline else {
            throw APIError.networkError(NSError(domain: "NetworkManager", code: -1009, userInfo: nil))
        }
        
        await MainActor.run { self.isLoading = true }
        defer {
            Task { @MainActor in self.isLoading = false }
        }
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .post,
            parameters: parameters
        )
    }
    
    /// Perform PUT request
    func put<T: Decodable & Sendable>(
        endpoint: String,
        parameters: [String: Any]
    ) async throws -> T {
        guard isOnline else {
            throw APIError.networkError(NSError(domain: "NetworkManager", code: -1009, userInfo: nil))
        }
        
        await MainActor.run { self.isLoading = true }
        defer {
            Task { @MainActor in self.isLoading = false }
        }
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .put,
            parameters: parameters
        )
    }
    
    /// Perform PATCH request
    func patch<T: Decodable & Sendable>(
        endpoint: String,
        parameters: [String: Any]
    ) async throws -> T {
        guard isOnline else {
            throw APIError.networkError(NSError(domain: "NetworkManager", code: -1009, userInfo: nil))
        }
        
        await MainActor.run { self.isLoading = true }
        defer {
            Task { @MainActor in self.isLoading = false }
        }
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .patch,
            parameters: parameters
        )
    }
    
    /// Perform DELETE request
    func delete<T: Decodable & Sendable>(
        endpoint: String
    ) async throws -> T {
        guard isOnline else {
            throw APIError.networkError(NSError(domain: "NetworkManager", code: -1009, userInfo: nil))
        }
        
        await MainActor.run { self.isLoading = true }
        defer {
            Task { @MainActor in self.isLoading = false }
        }
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .delete
        )
    }
    
    /// Upload image
    func uploadImage<T: Decodable & Sendable>(
        endpoint: String,
        imageData: Data,
        fileName: String = "image.jpg",
        parameters: [String: String]? = nil
    ) async throws -> T {
        guard isOnline else {
            throw APIError.networkError(NSError(domain: "NetworkManager", code: -1009, userInfo: nil))
        }
        
        await MainActor.run { self.isLoading = true }
        defer {
            Task { @MainActor in self.isLoading = false }
        }
        
        return try await apiClient.upload(
            endpoint: endpoint,
            data: imageData,
            fileName: fileName,
            parameters: parameters
        )
    }
    
    // MARK: - Token Management
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        return apiClient.accessToken != nil
    }
    
    /// Clear authentication tokens (logout)
    func clearAuthentication() {
        apiClient.clearTokens()
    }
    
    // MARK: - Error Handling
    
    /// Convert APIError to user-friendly message
    func friendlyErrorMessage(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.localizedDescription
        }
        return Constants.ErrorMessages.genericError
    }
}

// MARK: - Request Builder Helper
extension NetworkManager {
    
    /// Build query parameters string
    static func buildQueryString(from parameters: [String: Any]) -> String {
        var components = URLComponents()
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        return components.query ?? ""
    }
    
    /// Convert parameters to JSON Data
    static func parametersToJSON(_ parameters: [String: Any]) -> Data? {
        try? JSONSerialization.data(withJSONObject: parameters, options: [])
    }
}
