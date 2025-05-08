# Secure API Proxy Pattern App

A Swift console application that demonstrates the Proxy design pattern through a secure API access control system.

## Overview

This application simulates a secure API gateway that controls access to various endpoints based on authentication, authorization, and other security measures. The Proxy pattern is used to add a security layer in front of the actual API service, ensuring that only authorized requests reach the real service.

## Design Pattern: Proxy

The Proxy pattern is a structural design pattern that provides a surrogate or placeholder for another object to control access to it. It creates a representative object that controls access to another object, which may be remote, expensive to create, or in need of securing.

### Types of Proxies Demonstrated

1. **Protection Proxy**: Controls access to the original object based on access rights (primary focus of this app)
2. **Logging Proxy**: Keeps a record of requests to the service
3. **Caching Proxy**: Stores results of expensive operations for reuse

### Key Components in This Implementation

1. **Subject (`APIService` protocol)**: Defines the common interface for RealSubject and Proxy
2. **RealSubject (`RealAPIService` class)**: The real service that the proxy represents
3. **Proxy (`APIServiceProxy` class)**: Controls access to the RealSubject and adds security features
4. **Client (`APIClient` class)**: Uses the Subject interface to work with both RealSubject and Proxy

## Project Structure

```
SecureAPIProxyPatternApp/
├── Sources/
│   ├── APIService.swift       # Subject interface and supporting types
│   ├── RealAPIService.swift   # Real implementation of the API service
│   ├── APIServiceProxy.swift  # Proxy that controls access to the real service
│   ├── APIClient.swift        # Client that uses the API service
│   └── main.swift             # Application entry point
└── Package.swift              # Swift package definition
```

## Features

- Authentication and authorization checks before API access
- Role-based access control (guest, user, premium, admin)
- Rate limiting to prevent abuse
- Request validation and sanitization
- Logging of all API requests and responses
- Caching of responses for improved performance
- Metrics collection for monitoring and analytics
- Encryption of sensitive data
- Throttling for specific endpoints or users

## How the Proxy Pattern is Applied

In this application:

1. The `APIService` protocol defines methods like `request()` that both the real service and proxy implement
2. The `RealAPIService` class provides the actual implementation of the API service
3. The `APIServiceProxy` class:
   - Implements the same interface as `RealAPIService`
   - Contains a reference to a `RealAPIService` instance
   - Performs security checks before delegating to the real service:
     - Validates authentication tokens
     - Checks user permissions based on roles
     - Enforces rate limits
     - Logs request details
     - Caches responses when appropriate
4. The client code works with both the proxy and real service through the common interface

### Security Layers Implemented by the Proxy

The proxy implements multiple security layers:

1. **Authentication**: Verifies that the user has a valid token
2. **Authorization**: Checks if the user's role allows access to the requested endpoint
3. **Input Validation**: Sanitizes and validates request parameters
4. **Rate Limiting**: Prevents too many requests from the same user
5. **Logging**: Records all access attempts for auditing
6. **Encryption**: Encrypts sensitive data in transit

## Benefits of the Proxy Pattern

1. **Separation of Concerns**: Security logic is separated from the core API functionality
2. **Open/Closed Principle**: New security measures can be added without modifying the real service
3. **Single Responsibility**: The real service focuses on business logic while the proxy handles security
4. **Transparency**: Clients can work with the proxy as if it were the real service
5. **Control**: Provides fine-grained control over access to the real service

## Running the Application

To run the application:

```bash
cd /path/to/SecureAPIProxyPatternApp
swift build
swift run
```

## Usage Example

The application simulates various API requests with different user roles and authentication states:

1. Unauthenticated requests to public endpoints (allowed)
2. Unauthenticated requests to protected endpoints (denied)
3. Authenticated requests with insufficient permissions (denied)
4. Authenticated requests with proper permissions (allowed)
5. Requests that exceed rate limits (denied)
6. Requests with invalid parameters (denied)

The console output shows the decision-making process of the proxy and the results of each request.

## Implementation Details

- The application uses Swift's protocol-oriented programming approach
- Error handling is implemented to provide meaningful feedback on access denials
- The proxy demonstrates several variations of the pattern (protection, logging, caching)
- Metrics collection is implemented to monitor system usage
- The design allows for easy extension with additional security features
