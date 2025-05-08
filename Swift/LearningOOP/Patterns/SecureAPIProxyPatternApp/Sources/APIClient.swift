// APIClient.swift - Client for demonstrating the Proxy Pattern

import Foundation

// APIClient demonstrates how to use the APIServiceProxy
class APIClient {
    private let apiService: APIService
    private var currentRole: UserRole = .guest
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    // Login with a specific role
    func login(as role: UserRole, completion: @escaping (Bool) -> Void) {
        print("\n🔐 Logging in as \(role.rawValue)...")
        
        // In a real app, this would make an authentication request
        // For this demo, we'll simulate the authentication process
        
        // Create a token that expires in 1 hour
        let token = AuthToken(
            token: UUID().uuidString,
            expiresAt: Date().addingTimeInterval(3600),
            userRole: role
        )
        
        // Set the token in the proxy if it's a proxy
        if let proxy = apiService as? APIServiceProxy {
            proxy.setAuthToken(token)
        }
        
        currentRole = role
        
        print("✅ Successfully logged in as \(role.rawValue)")
        completion(true)
    }
    
    // Logout
    func logout() {
        print("\n🔒 Logging out...")
        
        // Clear the token in the proxy if it's a proxy
        if let proxy = apiService as? APIServiceProxy {
            proxy.clearAuthToken()
        }
        
        currentRole = .guest
        
        print("✅ Successfully logged out")
    }
    
    // Get user profile
    func getUserProfile(completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        print("\n📱 Fetching user profile...")
        
        apiService.request(
            endpoint: .userProfile,
            method: .get,
            parameters: APIParameters()
        ) { result in
            switch result {
            case .success(let response):
                print("✅ User profile fetched successfully")
                completion(.success(response.data))
            case .failure(let error):
                print("❌ Failed to fetch user profile: \(error.description)")
                completion(.failure(error))
            }
        }
    }
    
    // Get user settings
    func getUserSettings(completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        print("\n⚙️ Fetching user settings...")
        
        apiService.request(
            endpoint: .userSettings,
            method: .get,
            parameters: APIParameters()
        ) { result in
            switch result {
            case .success(let response):
                print("✅ User settings fetched successfully")
                completion(.success(response.data))
            case .failure(let error):
                print("❌ Failed to fetch user settings: \(error.description)")
                completion(.failure(error))
            }
        }
    }
    
    // Get public data
    func getPublicData(completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        print("\n🌐 Fetching public data...")
        
        apiService.request(
            endpoint: .publicData,
            method: .get,
            parameters: APIParameters()
        ) { result in
            switch result {
            case .success(let response):
                print("✅ Public data fetched successfully")
                completion(.success(response.data))
            case .failure(let error):
                print("❌ Failed to fetch public data: \(error.description)")
                completion(.failure(error))
            }
        }
    }
    
    // Get admin dashboard
    func getAdminDashboard(completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        print("\n👑 Fetching admin dashboard...")
        
        apiService.request(
            endpoint: .adminDashboard,
            method: .get,
            parameters: APIParameters()
        ) { result in
            switch result {
            case .success(let response):
                print("✅ Admin dashboard fetched successfully")
                completion(.success(response.data))
            case .failure(let error):
                print("❌ Failed to fetch admin dashboard: \(error.description)")
                completion(.failure(error))
            }
        }
    }
    
    // Get system metrics
    func getSystemMetrics(completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        print("\n📊 Fetching system metrics...")
        
        apiService.request(
            endpoint: .systemMetrics,
            method: .get,
            parameters: APIParameters()
        ) { result in
            switch result {
            case .success(let response):
                print("✅ System metrics fetched successfully")
                completion(.success(response.data))
            case .failure(let error):
                print("❌ Failed to fetch system metrics: \(error.description)")
                completion(.failure(error))
            }
        }
    }
    
    // Get payment information
    func getPaymentInfo(completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        print("\n💳 Fetching payment information...")
        
        apiService.request(
            endpoint: .paymentInfo,
            method: .get,
            parameters: APIParameters()
        ) { result in
            switch result {
            case .success(let response):
                print("✅ Payment information fetched successfully")
                completion(.success(response.data))
            case .failure(let error):
                print("❌ Failed to fetch payment information: \(error.description)")
                completion(.failure(error))
            }
        }
    }
    
    // Get analytics data
    func getAnalyticsData(completion: @escaping (Result<[String: Any], APIError>) -> Void) {
        print("\n📈 Fetching analytics data...")
        
        apiService.request(
            endpoint: .analyticsData,
            method: .get,
            parameters: APIParameters()
        ) { result in
            switch result {
            case .success(let response):
                print("✅ Analytics data fetched successfully")
                completion(.success(response.data))
            case .failure(let error):
                print("❌ Failed to fetch analytics data: \(error.description)")
                completion(.failure(error))
            }
        }
    }
    
    // Print data in a formatted way
    func printData(_ data: [String: Any], title: String) {
        print("\n=== \(title) ===")
        printDictionary(data, indent: 2)
        print("==================\n")
    }
    
    // Helper method to print dictionaries recursively
    private func printDictionary(_ dict: [String: Any], indent: Int) {
        let indentation = String(repeating: " ", count: indent)
        
        for (key, value) in dict.sorted(by: { $0.key < $1.key }) {
            if let nestedDict = value as? [String: Any] {
                print("\(indentation)\(key):")
                printDictionary(nestedDict, indent: indent + 2)
            } else if let array = value as? [[String: Any]] {
                print("\(indentation)\(key):")
                for (index, item) in array.enumerated() {
                    print("\(indentation)  [\(index)]:")
                    printDictionary(item, indent: indent + 4)
                }
            } else if let array = value as? [Any] {
                print("\(indentation)\(key): \(array)")
            } else {
                print("\(indentation)\(key): \(value)")
            }
        }
    }
}
