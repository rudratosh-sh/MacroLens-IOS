//
//  APIClient.swift
//  MacroLens
//
//  Path: MacroLens/Services/APIClient.swift
//

import Foundation
import Alamofire
import KeychainAccess

// MARK: - API Error Types
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case networkError(Error)
    case decodingError(Error)
    case validationError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return Constants.ErrorMessages.authenticationError
        case .forbidden:
            return Constants.ErrorMessages.unauthorizedError
        case .notFound:
            return Constants.ErrorMessages.notFoundError
        case .serverError(let code):
            return "Server error (Code: \(code))"
        case .networkError:
            return Constants.ErrorMessages.networkError
        case .decodingError:
            return "Failed to parse server response"
        case .validationError(let message):
            return message
        case .unknown:
            return Constants.ErrorMessages.genericError
        }
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Response
struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

// MARK: - API Client
class APIClient: @unchecked Sendable {
    
    // MARK: - Singleton
    static let shared = APIClient()
    
    // MARK: - Properties
    private let session: Session
    private let keychain = Keychain(service: Config.App.bundleIdentifier)
    
    // MARK: - Initialization
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Config.API.requestTimeout
        configuration.timeoutIntervalForResource = Config.API.resourceTimeout
        
        let interceptor = AuthInterceptor()
        
        self.session = Session(
            configuration: configuration,
            interceptor: interceptor
        )
    }
    
    // MARK: - Token Management
    var accessToken: String? {
        get { try? keychain.get(Config.StorageKeys.accessToken) }
        set {
            if let token = newValue {
                try? keychain.set(token, key: Config.StorageKeys.accessToken)
            } else {
                try? keychain.remove(Config.StorageKeys.accessToken)
            }
        }
    }
    
    var refreshToken: String? {
        get { try? keychain.get(Config.StorageKeys.refreshToken) }
        set {
            if let token = newValue {
                try? keychain.set(token, key: Config.StorageKeys.refreshToken)
            } else {
                try? keychain.remove(Config.StorageKeys.refreshToken)
            }
        }
    }
    
    // MARK: - Request Methods
    
    /// Generic request method
    func request<T: Decodable & Sendable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        
        guard let url = buildURL(endpoint: endpoint) else {
            throw APIError.invalidURL
        }
        
        Config.Logging.log("API Request: \(method.rawValue) \(url)", level: .info)
        
        var requestHeaders = headers ?? HTTPHeaders()
        
        // Add authorization header if token exists
        if let token = accessToken {
            requestHeaders.add(.authorization(bearerToken: token))
        }
        
        requestHeaders.add(.contentType("application/json"))
        requestHeaders.add(.accept("application/json"))
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: Alamofire.HTTPMethod(rawValue: method.rawValue),
                parameters: parameters,
                encoding: encoding,
                headers: requestHeaders
            )
            .validate()
            .responseDecodable(of: APIResponse<T>.self, queue: .global(qos: .userInitiated)) { response in
                self.handleResponse(response, continuation: continuation)
            }
        }
    }
    
    /// Upload request with multipart form data
    func upload<T: Decodable & Sendable>(
        endpoint: String,
        data: Data,
        fileName: String,
        mimeType: String = "image/jpeg",
        parameters: [String: String]? = nil
    ) async throws -> T {
        
        guard let url = buildURL(endpoint: endpoint) else {
            throw APIError.invalidURL
        }
        
        Config.Logging.log("API Upload: POST \(url)", level: .info)
        
        var requestHeaders = HTTPHeaders()
        if let token = accessToken {
            requestHeaders.add(.authorization(bearerToken: token))
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        data,
                        withName: "file",
                        fileName: fileName,
                        mimeType: mimeType
                    )
                    
                    parameters?.forEach { key, value in
                        if let data = value.data(using: .utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                },
                to: url,
                headers: requestHeaders
            )
            .validate()
            .responseDecodable(of: APIResponse<T>.self, queue: .global(qos: .userInitiated)) { response in
                self.handleResponse(response, continuation: continuation)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func buildURL(endpoint: String) -> URL? {
        let baseURL = Config.API.fullBaseURL
        let fullPath = endpoint.hasPrefix("/") ? endpoint : "/\(endpoint)"
        return URL(string: baseURL + fullPath)
    }
    
    private func handleResponse<T: Decodable & Sendable>(
        _ response: DataResponse<APIResponse<T>, AFError>,
        continuation: CheckedContinuation<T, Error>
    ) {
        
        switch response.result {
        case .success(let apiResponse):
            
            if apiResponse.success, let data = apiResponse.data {
                Config.Logging.log("API Success: \(response.request?.url?.absoluteString ?? "")", level: .info)
                continuation.resume(returning: data)
            } else {
                let errorMessage = apiResponse.error ?? apiResponse.message ?? Constants.ErrorMessages.genericError
                Config.Logging.log("API Error: \(errorMessage)", level: .error)
                continuation.resume(throwing: APIError.validationError(errorMessage))
            }
            
        case .failure(let error):
            Config.Logging.log("API Failure: \(error.localizedDescription)", level: .error)
            
            let apiError = self.mapAFError(error, statusCode: response.response?.statusCode)
            continuation.resume(throwing: apiError)
        }
    }
    
    private func mapAFError(_ error: AFError, statusCode: Int?) -> APIError {
        if let statusCode = statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 500...599:
                return .serverError(statusCode)
            default:
                break
            }
        }
        
        if error.isSessionTaskError {
            return .networkError(error)
        }
        
        if error.isResponseSerializationError {
            return .decodingError(error)
        }
        
        return .unknown
    }
    
    // MARK: - Clear Tokens (Logout)
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }
}

// MARK: - Auth Interceptor
class AuthInterceptor: RequestInterceptor {
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        
        urlRequest.setValue(Config.App.version, forHTTPHeaderField: "X-App-Version")
        urlRequest.setValue("iOS", forHTTPHeaderField: "X-Platform")
        
        completion(.success(urlRequest))
    }
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        completion(.doNotRetry)
    }
}
