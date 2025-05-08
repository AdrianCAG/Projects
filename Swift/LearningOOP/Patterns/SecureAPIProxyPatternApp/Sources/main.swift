// main.swift - Entry point for the SecureAPIProxyPatternApp

import Foundation

// Print a welcome banner
print("""
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║             Secure API Proxy Pattern Demo                      ║
║                                                                ║
║  This application demonstrates the Proxy Design Pattern        ║
║  by implementing a secure API access system where the proxy    ║
║  controls access to sensitive API endpoints, handles           ║
║  authentication, caching, and logging.                         ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
""")

// Explain the Proxy Pattern
print("""
The Proxy Pattern provides a surrogate or placeholder for another object to control access to it.
This pattern is particularly useful for implementing features like:
  • Access control
  • Caching
  • Logging
  • Lazy initialization
  • Remote resource access

In this application:
  • APIService is the Subject interface
  • RealAPIService is the Real Subject that performs the actual work
  • APIServiceProxy is the Proxy that controls access to the Real Subject
  • APIClient is the Client that uses the Proxy

Let's see the pattern in action!
""")

// Create the real service
let realService = RealAPIService(baseURL: "https://api.example.com")

// Create the proxy with various features enabled
let proxyService = APIServiceProxy(
    realService: realService,
    cacheEnabled: true,
    loggingEnabled: true,
    rateLimitingEnabled: true
)

// Create the client using the proxy
let client = APIClient(apiService: proxyService)

// Create a dispatch group to manage async operations
let group = DispatchGroup()

// Function to wait for async operations to complete
func waitForCompletion() {
    group.wait()
    Thread.sleep(forTimeInterval: 0.5) // Add a small delay for readability
}

// DEMO 1: Access without authentication
print("\n=== DEMO 1: Access without authentication ===")

// Try to access public data (should succeed)
group.enter()
client.getPublicData { result in
    if case .success(let data) = result {
        client.printData(data, title: "Public Data")
    }
    group.leave()
}
waitForCompletion()

// Try to access user profile (should fail)
group.enter()
client.getUserProfile { _ in
    group.leave()
}
waitForCompletion()

// DEMO 2: Regular user access
print("\n=== DEMO 2: Regular user access ===")

// Login as a regular user
group.enter()
client.login(as: .user) { _ in
    group.leave()
}
waitForCompletion()

// Access user profile (should succeed)
group.enter()
client.getUserProfile { result in
    if case .success(let data) = result {
        client.printData(data, title: "User Profile")
    }
    group.leave()
}
waitForCompletion()

// Access user settings (should succeed)
group.enter()
client.getUserSettings { result in
    if case .success(let data) = result {
        client.printData(data, title: "User Settings")
    }
    group.leave()
}
waitForCompletion()

// Access payment info (should succeed)
group.enter()
client.getPaymentInfo { result in
    if case .success(let data) = result {
        client.printData(data, title: "Payment Info")
    }
    group.leave()
}
waitForCompletion()

// Try to access admin dashboard (should fail)
group.enter()
client.getAdminDashboard { _ in
    group.leave()
}
waitForCompletion()

// DEMO 3: Premium user access
print("\n=== DEMO 3: Premium user access ===")

// Login as a premium user
group.enter()
client.login(as: .premium) { _ in
    group.leave()
}
waitForCompletion()

// Access analytics data (should succeed)
group.enter()
client.getAnalyticsData { result in
    if case .success(let data) = result {
        client.printData(data, title: "Analytics Data")
    }
    group.leave()
}
waitForCompletion()

// DEMO 4: Admin access
print("\n=== DEMO 4: Admin access ===")

// Login as an admin
group.enter()
client.login(as: .admin) { _ in
    group.leave()
}
waitForCompletion()

// Access admin dashboard (should succeed)
group.enter()
client.getAdminDashboard { result in
    if case .success(let data) = result {
        client.printData(data, title: "Admin Dashboard")
    }
    group.leave()
}
waitForCompletion()

// Access system metrics (should succeed)
group.enter()
client.getSystemMetrics { result in
    if case .success(let data) = result {
        client.printData(data, title: "System Metrics")
    }
    group.leave()
}
waitForCompletion()

// DEMO 5: Caching
print("\n=== DEMO 5: Caching ===")
print("Making two identical requests to demonstrate caching...")

// Make first request
group.enter()
client.getPublicData { _ in
    group.leave()
}
waitForCompletion()

// Make second request (should be served from cache)
group.enter()
client.getPublicData { _ in
    group.leave()
}
waitForCompletion()

// DEMO 6: Logout
print("\n=== DEMO 6: Logout ===")

// Logout
client.logout()

// Try to access user profile after logout (should fail)
group.enter()
client.getUserProfile { _ in
    group.leave()
}
waitForCompletion()

// Conclusion
print("""
\n=== Proxy Pattern Demo Conclusion ===

This demo has shown how the Proxy Pattern can be used to:

1. Control access to resources based on authentication and authorization
2. Implement caching to improve performance
3. Add logging for debugging and monitoring
4. Implement rate limiting to prevent abuse

The key benefit of the Proxy Pattern is that it allows you to add these
features without modifying the Real Subject, adhering to the Open/Closed
Principle of SOLID design.

The client code interacts with the same interface whether it's using
the Real Subject directly or through the Proxy, making the pattern
transparent to clients.
""")
