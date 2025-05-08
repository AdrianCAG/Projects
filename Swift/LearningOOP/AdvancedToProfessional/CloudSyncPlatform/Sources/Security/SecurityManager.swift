import Foundation
import Crypto
import Logging

/// Security Manager - Handles encryption, decryption, and authentication
class SecurityManager {
    // MARK: - Singleton
    
    static let shared = SecurityManager()
    
    // MARK: - Properties
    
    private let logger = Logger(label: "com.cloudsync.security")
    
    // In a real app, these would be securely stored
    private var encryptionKey: SymmetricKey?
    private var authToken: String?
    
    // MARK: - Initialization
    
    private init() {
        logger.info("SecurityManager initialized")
    }
    
    // MARK: - Authentication Methods
    
    /// Authenticate a user
    /// - Parameters:
    ///   - username: Username
    ///   - password: Password
    /// - Returns: Authentication token
    func authenticate(username: String, password: String) -> String? {
        // In a real app, this would validate against a server or local database
        // For demo purposes, we'll accept any non-empty credentials
        
        guard !username.isEmpty, !password.isEmpty else {
            logger.warning("Authentication failed: Empty credentials")
            return nil
        }
        
        // Generate a token
        let token = generateToken(for: username)
        self.authToken = token
        
        logger.info("User authenticated: \(username)")
        return token
    }
    
    /// Check if a token is valid
    /// - Parameter token: Token to validate
    /// - Returns: Whether the token is valid
    func validateToken(_ token: String) -> Bool {
        // In a real app, this would validate against a server or check expiration
        // For demo purposes, we'll just check if it matches our stored token
        
        guard let authToken = self.authToken else {
            return false
        }
        
        return token == authToken
    }
    
    /// Sign out the current user
    func signOut() {
        self.authToken = nil
        logger.info("User signed out")
    }
    
    // MARK: - Encryption Methods
    
    /// Initialize encryption with a key
    /// - Parameter key: Key data
    func initializeEncryption(withKey key: Data) {
        // In a real app, this would use a proper key derivation function
        // For demo purposes, we'll just use the raw data
        
        self.encryptionKey = SymmetricKey(data: key)
        logger.info("Encryption initialized")
    }
    
    /// Generate a new encryption key
    /// - Returns: Key data
    func generateEncryptionKey() -> Data {
        // Generate a random key
        let key = SymmetricKey(size: .bits256)
        self.encryptionKey = key
        
        logger.info("Generated new encryption key")
        return key.withUnsafeBytes { Data($0) }
    }
    
    /// Encrypt data
    /// - Parameter data: Data to encrypt
    /// - Returns: Encrypted data
    func encrypt(_ data: Data) throws -> Data {
        guard let key = encryptionKey else {
            let error = NSError(domain: "com.cloudsync.security", code: 500, userInfo: [NSLocalizedDescriptionKey: "Encryption key not initialized"])
            logger.error("Encryption failed: Key not initialized")
            throw error
        }
        
        // Use AES-GCM for authenticated encryption
        let sealedBox = try AES.GCM.seal(data, using: key)
        
        guard let combined = sealedBox.combined else {
            let error = NSError(domain: "com.cloudsync.security", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to combine sealed box"])
            logger.error("Encryption failed: Could not combine sealed box")
            throw error
        }
        
        return combined
    }
    
    /// Decrypt data
    /// - Parameter data: Data to decrypt
    /// - Returns: Decrypted data
    func decrypt(_ data: Data) throws -> Data {
        guard let key = encryptionKey else {
            let error = NSError(domain: "com.cloudsync.security", code: 500, userInfo: [NSLocalizedDescriptionKey: "Encryption key not initialized"])
            logger.error("Decryption failed: Key not initialized")
            throw error
        }
        
        // Use AES-GCM for authenticated decryption
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    /// Hash a password
    /// - Parameter password: Password to hash
    /// - Returns: Password hash
    func hashPassword(_ password: String) -> String {
        // In a real app, this would use a proper password hashing function like bcrypt
        // For demo purposes, we'll just use SHA-256
        
        guard let data = password.data(using: .utf8) else {
            return ""
        }
        
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - Helper Methods
    
    /// Generate an authentication token
    /// - Parameter username: Username
    /// - Returns: Authentication token
    private func generateToken(for username: String) -> String {
        // In a real app, this would generate a proper JWT or similar token
        // For demo purposes, we'll just create a simple token
        
        let timestamp = Date().timeIntervalSince1970
        let randomPart = UUID().uuidString
        
        let tokenString = "\(username):\(timestamp):\(randomPart)"
        guard let data = tokenString.data(using: .utf8) else {
            return UUID().uuidString
        }
        
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
