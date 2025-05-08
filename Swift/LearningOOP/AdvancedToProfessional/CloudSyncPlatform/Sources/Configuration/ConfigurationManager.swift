import Foundation
import Logging

/// Configuration Manager using the Singleton pattern
/// Responsible for loading and providing access to application configuration
final class ConfigurationManager {
    // MARK: - Singleton
    
    /// Shared instance (Singleton pattern)
    static let shared = ConfigurationManager()
    
    // MARK: - Properties
    
    /// Logger instance
    private let logger = Logger(label: "com.cloudsync.configuration")
    
    /// Configuration values
    private var configValues: [String: Any] = [:]
    
    /// Default configuration
    private let defaultConfig: [String: Any] = [
        "syncInterval": 300, // 5 minutes
        "maxFileSize": 1024 * 1024 * 100, // 100 MB
        "chunkSize": 1024 * 1024, // 1 MB
        "maxConcurrentUploads": 3,
        "maxConcurrentDownloads": 5,
        "encryptionEnabled": true,
        "compressionEnabled": true,
        "retryAttempts": 3,
        "retryDelay": 5.0, // seconds
        "logLevel": "info",
        "tempDirectory": NSTemporaryDirectory(),
        "defaultCloudProvider": "aws",
        "autoSyncEnabled": true
    ]
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {
        loadDefaultConfiguration()
    }
    
    // MARK: - Configuration Methods
    
    /// Load default configuration
    private func loadDefaultConfiguration() {
        configValues = defaultConfig
        logger.info("Loaded default configuration")
    }
    
    /// Load configuration from file
    /// - Parameter path: Path to configuration file
    /// - Returns: Success or failure
    @discardableResult
    func loadConfiguration(from path: String) -> Bool {
        guard let configFileURL = URL(string: path) else {
            logger.error("Invalid configuration file path: \(path)")
            return false
        }
        
        do {
            let data = try Data(contentsOf: configFileURL)
            
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // Merge with defaults
                for (key, value) in jsonObject {
                    configValues[key] = value
                }
                logger.info("Successfully loaded configuration from \(path)")
                return true
            } else {
                logger.error("Failed to parse configuration file as JSON dictionary")
                return false
            }
        } catch {
            logger.error("Failed to load configuration: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Save configuration to file
    /// - Parameter path: Path to save configuration
    /// - Returns: Success or failure
    @discardableResult
    func saveConfiguration(to path: String) -> Bool {
        guard let configFileURL = URL(string: path) else {
            logger.error("Invalid configuration file path: \(path)")
            return false
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: configValues, options: .prettyPrinted)
            try data.write(to: configFileURL, options: .atomic)
            logger.info("Successfully saved configuration to \(path)")
            return true
        } catch {
            logger.error("Failed to save configuration: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Get a configuration value
    /// - Parameters:
    ///   - key: Configuration key
    ///   - defaultValue: Default value if key doesn't exist
    /// - Returns: Configuration value
    func getValue<T>(for key: String, defaultValue: T) -> T {
        guard let value = configValues[key] as? T else {
            return defaultValue
        }
        return value
    }
    
    /// Set a configuration value
    /// - Parameters:
    ///   - value: Value to set
    ///   - key: Configuration key
    func setValue(_ value: Any, for key: String) {
        configValues[key] = value
        logger.debug("Set configuration value for \(key)")
    }
    
    /// Reset configuration to defaults
    func resetToDefaults() {
        configValues = defaultConfig
        logger.info("Reset configuration to defaults")
    }
}
