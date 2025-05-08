// APIServiceProxy.swift - Proxy in the Proxy Pattern

import Foundation

// User role for access control
enum UserRole: String {
    case guest
    case user
    case premium
    case admin
    
    var canAccessAdminEndpoints: Bool {
        return self == .admin
    }
    
    var canAccessPaymentInfo: Bool {
        return self == .admin || self == .premium || self == .user
    }
    
    var canAccessAnalytics: Bool {
        return self == .admin || self == .premium
    }
}

// Authentication token structure
struct AuthToken {
    let token: String
    let expiresAt: Date
    let userRole: UserRole
    
    var isValid: Bool {
        return expiresAt > Date()
    }
}

// APIServiceProxy implements the same interface as RealAPIService but adds:
// 1. Authentication and authorization checks
// 2. Caching
// 3. Rate limiting
// 4. Logging
class APIServiceProxy: APIService {
    private let realService: RealAPIService
    private var authToken: AuthToken?
    private var cache: [String: (response: APIResponse, expiresAt: Date)] = [:]
    private var requestCounts: [String: Int] = [:]
    private var lastRequestTimes: [String: Date] = [:]
    private let rateLimitPerMinute: Int = 60
    private let cacheEnabled: Bool
    private let loggingEnabled: Bool
    private let rateLimitingEnabled: Bool
    
    init(
        realService: RealAPIService,
        cacheEnabled: Bool = true,
        loggingEnabled: Bool = true,
        rateLimitingEnabled: Bool = true
    ) {
        self.realService = realService
        self.cacheEnabled = cacheEnabled
        self.loggingEnabled = loggingEnabled
        self.rateLimitingEnabled = rateLimitingEnabled
    }
    
    // Set the authentication token
    func setAuthToken(_ token: AuthToken) {
        self.authToken = token
        if loggingEnabled {
            print("🔑 APIServiceProxy: Authentication token set for role: \(token.userRole.rawValue)")
        }
    }
    
    // Clear the authentication token (logout)
    func clearAuthToken() {
        self.authToken = nil
        if loggingEnabled {
            print("🔒 APIServiceProxy: Authentication token cleared")
        }
    }
    
    // Clear the cache
    func clearCache() {
        cache.removeAll()
        if loggingEnabled {
            print("🧹 APIServiceProxy: Cache cleared")
        }
    }
    
    // Reset rate limiting counters
    func resetRateLimits() {
        requestCounts.removeAll()
        lastRequestTimes.removeAll()
        if loggingEnabled {
            print("⏱️ APIServiceProxy: Rate limits reset")
        }
    }
    
    // Implementation of the APIService protocol method
    func request(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: APIParameters,
        completion: @escaping (Result<APIResponse, APIError>) -> Void
    ) {
        // 1. Log the request if logging is enabled
        if loggingEnabled {
            print("🔄 APIServiceProxy: Received \(method.rawValue) request for \(endpoint.rawValue)")
        }
        
        // 2. Check authentication if required
        if endpoint.requiresAuthentication {
            guard let token = authToken, token.isValid else {
                if loggingEnabled {
                    print("❌ APIServiceProxy: Authentication required for \(endpoint.rawValue)")
                }
                completion(.failure(.authenticationRequired))
                return
            }
            
            // 3. Check authorization for specific endpoints
            if endpoint.requiresAdminAccess && !token.userRole.canAccessAdminEndpoints {
                if loggingEnabled {
                    print("🚫 APIServiceProxy: Admin access required for \(endpoint.rawValue)")
                }
                completion(.failure(.accessDenied))
                return
            }
            
            if endpoint.requiresPaymentAccess && !token.userRole.canAccessPaymentInfo {
                if loggingEnabled {
                    print("🚫 APIServiceProxy: Payment access required for \(endpoint.rawValue)")
                }
                completion(.failure(.accessDenied))
                return
            }
            
            if endpoint == .analyticsData && !token.userRole.canAccessAnalytics {
                if loggingEnabled {
                    print("🚫 APIServiceProxy: Analytics access required for \(endpoint.rawValue)")
                }
                completion(.failure(.accessDenied))
                return
            }
        }
        
        // 4. Apply rate limiting if enabled
        if rateLimitingEnabled {
            let key = "\(endpoint.rawValue)_\(authToken?.userRole.rawValue ?? "guest")"
            
            // Reset counter if it's been more than a minute since the last request
            if let lastTime = lastRequestTimes[key], Date().timeIntervalSince(lastTime) > 60 {
                requestCounts[key] = 0
            }
            
            // Update request count
            let currentCount = requestCounts[key] ?? 0
            requestCounts[key] = currentCount + 1
            lastRequestTimes[key] = Date()
            
            // Check if rate limit exceeded
            if currentCount >= rateLimitPerMinute {
                if loggingEnabled {
                    print("⛔ APIServiceProxy: Rate limit exceeded for \(endpoint.rawValue)")
                }
                completion(.failure(.rateLimitExceeded))
                return
            }
        }
        
        // 5. Check cache for GET requests if caching is enabled
        if cacheEnabled && method == .get {
            let cacheKey = generateCacheKey(endpoint: endpoint, parameters: parameters)
            
            if let cachedData = cache[cacheKey], cachedData.expiresAt > Date() {
                if loggingEnabled {
                    print("📦 APIServiceProxy: Returning cached response for \(endpoint.rawValue)")
                }
                completion(.success(cachedData.response))
                return
            }
        }
        
        // 6. Forward the request to the real service
        realService.request(endpoint: endpoint, method: method, parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            
            // 7. Process the response
            switch result {
            case .success(let response):
                // Cache successful GET responses if caching is enabled
                if self.cacheEnabled && method == .get {
                    let cacheKey = self.generateCacheKey(endpoint: endpoint, parameters: parameters)
                    // Cache for 5 minutes
                    let expiresAt = Date().addingTimeInterval(300)
                    self.cache[cacheKey] = (response, expiresAt)
                    
                    if self.loggingEnabled {
                        print("💾 APIServiceProxy: Cached response for \(endpoint.rawValue)")
                    }
                }
                
                if self.loggingEnabled {
                    print("✅ APIServiceProxy: Request to \(endpoint.rawValue) completed successfully")
                }
                
            case .failure(let error):
                if self.loggingEnabled {
                    print("❌ APIServiceProxy: Request to \(endpoint.rawValue) failed: \(error.description)")
                }
            }
            
            // Pass the result back to the caller
            completion(result)
        }
    }
    
    // Cancel all requests
    func cancelAllRequests() {
        if loggingEnabled {
            print("🛑 APIServiceProxy: Cancelling all requests")
        }
        realService.cancelAllRequests()
    }
    
    // Generate a cache key for a request
    private func generateCacheKey(endpoint: APIEndpoint, parameters: APIParameters) -> String {
        let queryString = parameters.queryParams
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        
        return "\(endpoint.rawValue)?\(queryString)"
    }
}
