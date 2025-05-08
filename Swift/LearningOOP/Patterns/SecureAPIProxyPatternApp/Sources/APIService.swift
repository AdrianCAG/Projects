// APIService.swift - Subject interface for the Proxy Pattern

import Foundation

// Enum representing different API endpoints
enum APIEndpoint: String, CaseIterable {
    case userProfile = "/api/user/profile"
    case userSettings = "/api/user/settings"
    case publicData = "/api/public/data"
    case adminDashboard = "/api/admin/dashboard"
    case systemMetrics = "/api/system/metrics"
    case paymentInfo = "/api/user/payment"
    case analyticsData = "/api/analytics/data"
    
    // Properties to categorize endpoints
    var isPublic: Bool {
        switch self {
        case .publicData:
            return true
        default:
            return false
        }
    }
    
    var requiresAuthentication: Bool {
        return !isPublic
    }
    
    var requiresAdminAccess: Bool {
        switch self {
        case .adminDashboard, .systemMetrics:
            return true
        default:
            return false
        }
    }
    
    var requiresPaymentAccess: Bool {
        switch self {
        case .paymentInfo:
            return true
        default:
            return false
        }
    }
    
    var category: String {
        switch self {
        case .userProfile, .userSettings, .paymentInfo:
            return "User"
        case .publicData:
            return "Public"
        case .adminDashboard, .systemMetrics:
            return "Admin"
        case .analyticsData:
            return "Analytics"
        }
    }
}

// Enum representing HTTP methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// Structure representing API request parameters
struct APIParameters {
    let queryParams: [String: String]
    let bodyParams: [String: Any]
    
    init(queryParams: [String: String] = [:], bodyParams: [String: Any] = [:]) {
        self.queryParams = queryParams
        self.bodyParams = bodyParams
    }
}

// Structure representing API response
struct APIResponse {
    let statusCode: Int
    let data: [String: Any]
    let headers: [String: String]
    let timestamp: Date
    
    init(statusCode: Int, data: [String: Any], headers: [String: String] = [:]) {
        self.statusCode = statusCode
        self.data = data
        self.headers = headers
        self.timestamp = Date()
    }
    
    var isSuccess: Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    var isError: Bool {
        return !isSuccess
    }
    
    var isAuthError: Bool {
        return statusCode == 401 || statusCode == 403
    }
}

// Error types for API operations
enum APIError: Error {
    case invalidEndpoint
    case authenticationRequired
    case accessDenied
    case rateLimitExceeded
    case serverError(code: Int, message: String)
    case networkError(message: String)
    case invalidParameters
    case resourceNotFound
    
    var description: String {
        switch self {
        case .invalidEndpoint:
            return "Invalid API endpoint"
        case .authenticationRequired:
            return "Authentication required"
        case .accessDenied:
            return "Access denied"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidParameters:
            return "Invalid parameters"
        case .resourceNotFound:
            return "Resource not found"
        }
    }
}

// Protocol defining the API service interface (Subject)
protocol APIService {
    func request(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: APIParameters,
        completion: @escaping (Result<APIResponse, APIError>) -> Void
    )
    
    func cancelAllRequests()
}
