// RealAPIService.swift - Real Subject in the Proxy Pattern

import Foundation

// RealAPIService is the actual implementation of the APIService protocol
// This is the class that performs the real work and is protected by the proxy
class RealAPIService: APIService {
    private var activeRequests: [UUID: URLSessionDataTask] = [:]
    private let baseURL: String
    
    init(baseURL: String = "https://api.example.com") {
        self.baseURL = baseURL
    }
    
    // Implementation of the APIService protocol method
    func request(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: APIParameters,
        completion: @escaping (Result<APIResponse, APIError>) -> Void
    ) {
        // Log the request
        print("📡 RealAPIService: Making \(method.rawValue) request to \(endpoint.rawValue)")
        
        // In a real app, this would make an actual network request
        // For this demo, we'll simulate the network request with a delay
        let requestID = UUID()
        
        let task = URLSession.shared.dataTask(with: URL(string: baseURL)!) { _, _, _ in
            // This is just a placeholder - in a real app, this would process the response
        }
        
        // Store the task
        activeRequests[requestID] = task
        
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + Double.random(in: 0.5...1.5)) {
            // Remove the task from active requests
            self.activeRequests.removeValue(forKey: requestID)
            
            // Simulate response based on endpoint and parameters
            let response = self.simulateResponse(for: endpoint, method: method, parameters: parameters)
            completion(response)
        }
        
        // Start the task (in a real app)
        // task.resume()
    }
    
    // Cancel all active requests
    func cancelAllRequests() {
        print("🛑 RealAPIService: Cancelling all active requests")
        
        for (_, task) in activeRequests {
            task.cancel()
        }
        
        activeRequests.removeAll()
    }
    
    // Helper method to simulate API responses
    private func simulateResponse(
        for endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: APIParameters
    ) -> Result<APIResponse, APIError> {
        // Simulate different responses based on the endpoint
        switch endpoint {
        case .userProfile:
            return .success(APIResponse(
                statusCode: 200,
                data: [
                    "id": "user123",
                    "name": "John Doe",
                    "email": "john.doe@example.com",
                    "role": "user",
                    "createdAt": "2023-01-15T10:30:00Z"
                ],
                headers: ["Content-Type": "application/json"]
            ))
            
        case .userSettings:
            return .success(APIResponse(
                statusCode: 200,
                data: [
                    "theme": "dark",
                    "notifications": true,
                    "language": "en",
                    "timezone": "UTC-5"
                ],
                headers: ["Content-Type": "application/json"]
            ))
            
        case .publicData:
            return .success(APIResponse(
                statusCode: 200,
                data: [
                    "version": "2.1.0",
                    "apiStatus": "operational",
                    "serverTime": ISO8601DateFormatter().string(from: Date()),
                    "publicAnnouncements": [
                        ["id": 1, "title": "System Update", "content": "Scheduled maintenance on May 10"],
                        ["id": 2, "title": "New Features", "content": "Check out our latest features"]
                    ]
                ],
                headers: ["Content-Type": "application/json", "Cache-Control": "max-age=300"]
            ))
            
        case .adminDashboard:
            return .success(APIResponse(
                statusCode: 200,
                data: [
                    "activeUsers": 1250,
                    "newSignups": 47,
                    "revenue": 15420.50,
                    "systemStatus": "healthy",
                    "alerts": [
                        ["level": "warning", "message": "High CPU usage detected"],
                        ["level": "info", "message": "Daily backup completed"]
                    ]
                ],
                headers: ["Content-Type": "application/json"]
            ))
            
        case .systemMetrics:
            return .success(APIResponse(
                statusCode: 200,
                data: [
                    "cpu": 42.5,
                    "memory": 68.3,
                    "disk": 57.2,
                    "network": [
                        "inbound": 1250000,
                        "outbound": 780000
                    ],
                    "uptime": 1209600 // 14 days in seconds
                ],
                headers: ["Content-Type": "application/json"]
            ))
            
        case .paymentInfo:
            return .success(APIResponse(
                statusCode: 200,
                data: [
                    "paymentMethods": [
                        [
                            "id": "pm_1",
                            "type": "credit_card",
                            "last4": "4242",
                            "expiryMonth": 12,
                            "expiryYear": 2025
                        ],
                        [
                            "id": "pm_2",
                            "type": "paypal",
                            "email": "john.doe@example.com"
                        ]
                    ],
                    "billingAddress": [
                        "line1": "123 Main St",
                        "city": "Anytown",
                        "state": "CA",
                        "zip": "12345",
                        "country": "US"
                    ],
                    "subscriptionStatus": "active"
                ],
                headers: ["Content-Type": "application/json"]
            ))
            
        case .analyticsData:
            return .success(APIResponse(
                statusCode: 200,
                data: [
                    "pageViews": 25000,
                    "uniqueVisitors": 8500,
                    "bounceRate": 32.5,
                    "averageSessionDuration": 185, // seconds
                    "topReferrers": [
                        ["domain": "google.com", "visits": 12500],
                        ["domain": "facebook.com", "visits": 5000],
                        ["domain": "twitter.com", "visits": 3500]
                    ],
                    "topPages": [
                        ["path": "/", "views": 15000],
                        ["path": "/products", "views": 8000],
                        ["path": "/about", "views": 2000]
                    ]
                ],
                headers: ["Content-Type": "application/json"]
            ))
        }
    }
}
