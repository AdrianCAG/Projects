import Foundation
import RxSwift
import Logging
import Crypto

/// Storage Manager - Handles local file storage operations
class StorageManager {
    // MARK: - Singleton
    
    static let shared = StorageManager()
    
    // MARK: - Properties
    
    private let logger = Logger(label: "com.cloudsync.storage")
    private let fileManager = FileManager.default
    private let configManager = ConfigurationManager.shared
    
    /// Base directory for app storage
    private let baseDirectory: URL
    
    /// Files directory
    private let filesDirectory: URL
    
    /// Temp directory
    private let tempDirectory: URL
    
    /// Cache directory
    private let cacheDirectory: URL
    
    // MARK: - Initialization
    
    private init() {
        // Get app documents directory
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Failed to access documents directory")
        }
        
        // Set up base directory
        self.baseDirectory = documentsDirectory.appendingPathComponent("CloudSyncPlatform", isDirectory: true)
        
        // Set up subdirectories
        self.filesDirectory = baseDirectory.appendingPathComponent("Files", isDirectory: true)
        self.tempDirectory = baseDirectory.appendingPathComponent("Temp", isDirectory: true)
        self.cacheDirectory = baseDirectory.appendingPathComponent("Cache", isDirectory: true)
        
        // Create directories if needed
        createDirectoriesIfNeeded()
        
        logger.info("StorageManager initialized")
    }
    
    // MARK: - Directory Methods
    
    /// Create necessary directories
    private func createDirectoriesIfNeeded() {
        let directories = [baseDirectory, filesDirectory, tempDirectory, cacheDirectory]
        
        for directory in directories {
            do {
                if !fileManager.fileExists(atPath: directory.path) {
                    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                    logger.info("Created directory: \(directory.lastPathComponent)")
                }
            } catch {
                logger.error("Failed to create directory \(directory.lastPathComponent): \(error.localizedDescription)")
            }
        }
    }
    
    /// Get URL for a file path
    /// - Parameter path: Relative path
    /// - Returns: Full URL
    func getFileURL(for path: String) -> URL {
        return filesDirectory.appendingPathComponent(path)
    }
    
    /// Get URL for a temp file
    /// - Parameter filename: Filename
    /// - Returns: Temp file URL
    func getTempFileURL(for filename: String) -> URL {
        return tempDirectory.appendingPathComponent(filename)
    }
    
    /// Get URL for a cached file
    /// - Parameter key: Cache key
    /// - Returns: Cache file URL
    func getCacheFileURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key)
    }
    
    // MARK: - File Operations
    
    /// Save data to a file
    /// - Parameters:
    ///   - data: Data to save
    ///   - path: File path
    ///   - encrypt: Whether to encrypt the data
    /// - Returns: Observable with success or error
    func saveFile(data: Data, to path: String, encrypt: Bool = false) -> Observable<Void> {
        return Observable.create { observer in
            let fileURL = self.getFileURL(for: path)
            
            // Create parent directory if needed
            let directoryURL = fileURL.deletingLastPathComponent()
            if !self.fileManager.fileExists(atPath: directoryURL.path) {
                do {
                    try self.fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                } catch {
                    self.logger.error("Failed to create directory: \(error.localizedDescription)")
                    observer.onError(error)
                    return Disposables.create()
                }
            }
            
            // Process data (encrypt if needed)
            let dataToSave: Data
            if encrypt {
                do {
                    dataToSave = try self.encryptData(data)
                } catch {
                    self.logger.error("Failed to encrypt data: \(error.localizedDescription)")
                    observer.onError(error)
                    return Disposables.create()
                }
            } else {
                dataToSave = data
            }
            
            // Save file
            do {
                try dataToSave.write(to: fileURL, options: .atomic)
                self.logger.info("Saved file to \(path)")
                observer.onNext(())
                observer.onCompleted()
            } catch {
                self.logger.error("Failed to save file: \(error.localizedDescription)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    /// Load data from a file
    /// - Parameters:
    ///   - path: File path
    ///   - decrypt: Whether to decrypt the data
    /// - Returns: Observable with file data
    func loadFile(from path: String, decrypt: Bool = false) -> Observable<Data> {
        return Observable.create { observer in
            let fileURL = self.getFileURL(for: path)
            
            // Check if file exists
            guard self.fileManager.fileExists(atPath: fileURL.path) else {
                let error = NSError(domain: "com.cloudsync.storage", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(path)"])
                self.logger.error("File not found: \(path)")
                observer.onError(error)
                return Disposables.create()
            }
            
            // Load file
            do {
                let data = try Data(contentsOf: fileURL)
                
                // Process data (decrypt if needed)
                if decrypt {
                    do {
                        let decryptedData = try self.decryptData(data)
                        observer.onNext(decryptedData)
                    } catch {
                        self.logger.error("Failed to decrypt data: \(error.localizedDescription)")
                        observer.onError(error)
                        return Disposables.create()
                    }
                } else {
                    observer.onNext(data)
                }
                
                observer.onCompleted()
            } catch {
                self.logger.error("Failed to load file: \(error.localizedDescription)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    /// Delete a file
    /// - Parameter path: File path
    /// - Returns: Observable with success or error
    func deleteFile(at path: String) -> Observable<Void> {
        return Observable.create { observer in
            let fileURL = self.getFileURL(for: path)
            
            // Check if file exists
            guard self.fileManager.fileExists(atPath: fileURL.path) else {
                observer.onNext(()) // File doesn't exist, consider it deleted
                observer.onCompleted()
                return Disposables.create()
            }
            
            // Delete file
            do {
                try self.fileManager.removeItem(at: fileURL)
                self.logger.info("Deleted file at \(path)")
                observer.onNext(())
                observer.onCompleted()
            } catch {
                self.logger.error("Failed to delete file: \(error.localizedDescription)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    /// Move a file
    /// - Parameters:
    ///   - sourcePath: Source path
    ///   - destinationPath: Destination path
    /// - Returns: Observable with success or error
    func moveFile(from sourcePath: String, to destinationPath: String) -> Observable<Void> {
        return Observable.create { observer in
            let sourceURL = self.getFileURL(for: sourcePath)
            let destinationURL = self.getFileURL(for: destinationPath)
            
            // Check if source file exists
            guard self.fileManager.fileExists(atPath: sourceURL.path) else {
                let error = NSError(domain: "com.cloudsync.storage", code: 404, userInfo: [NSLocalizedDescriptionKey: "Source file not found: \(sourcePath)"])
                self.logger.error("Source file not found: \(sourcePath)")
                observer.onError(error)
                return Disposables.create()
            }
            
            // Create parent directory if needed
            let directoryURL = destinationURL.deletingLastPathComponent()
            if !self.fileManager.fileExists(atPath: directoryURL.path) {
                do {
                    try self.fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                } catch {
                    self.logger.error("Failed to create directory: \(error.localizedDescription)")
                    observer.onError(error)
                    return Disposables.create()
                }
            }
            
            // Move file
            do {
                try self.fileManager.moveItem(at: sourceURL, to: destinationURL)
                self.logger.info("Moved file from \(sourcePath) to \(destinationPath)")
                observer.onNext(())
                observer.onCompleted()
            } catch {
                self.logger.error("Failed to move file: \(error.localizedDescription)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    /// Copy a file
    /// - Parameters:
    ///   - sourcePath: Source path
    ///   - destinationPath: Destination path
    /// - Returns: Observable with success or error
    func copyFile(from sourcePath: String, to destinationPath: String) -> Observable<Void> {
        return Observable.create { observer in
            let sourceURL = self.getFileURL(for: sourcePath)
            let destinationURL = self.getFileURL(for: destinationPath)
            
            // Check if source file exists
            guard self.fileManager.fileExists(atPath: sourceURL.path) else {
                let error = NSError(domain: "com.cloudsync.storage", code: 404, userInfo: [NSLocalizedDescriptionKey: "Source file not found: \(sourcePath)"])
                self.logger.error("Source file not found: \(sourcePath)")
                observer.onError(error)
                return Disposables.create()
            }
            
            // Create parent directory if needed
            let directoryURL = destinationURL.deletingLastPathComponent()
            if !self.fileManager.fileExists(atPath: directoryURL.path) {
                do {
                    try self.fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                } catch {
                    self.logger.error("Failed to create directory: \(error.localizedDescription)")
                    observer.onError(error)
                    return Disposables.create()
                }
            }
            
            // Copy file
            do {
                try self.fileManager.copyItem(at: sourceURL, to: destinationURL)
                self.logger.info("Copied file from \(sourcePath) to \(destinationPath)")
                observer.onNext(())
                observer.onCompleted()
            } catch {
                self.logger.error("Failed to copy file: \(error.localizedDescription)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    /// List files in a directory
    /// - Parameter path: Directory path
    /// - Returns: Observable with file URLs
    func listFiles(in path: String) -> Observable<[URL]> {
        return Observable.create { observer in
            let directoryURL = self.getFileURL(for: path)
            
            // Check if directory exists
            guard self.fileManager.fileExists(atPath: directoryURL.path) else {
                observer.onNext([]) // Directory doesn't exist, return empty array
                observer.onCompleted()
                return Disposables.create()
            }
            
            // List files
            do {
                let fileURLs = try self.fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
                observer.onNext(fileURLs)
                observer.onCompleted()
            } catch {
                self.logger.error("Failed to list files: \(error.localizedDescription)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    /// Calculate MD5 hash for a file
    /// - Parameter path: File path
    /// - Returns: Observable with MD5 hash string
    func calculateMD5(for path: String) -> Observable<String> {
        return loadFile(from: path)
            .map { data in
                let hash = SHA256.hash(data: data)
                return hash.compactMap { String(format: "%02x", $0) }.joined()
            }
    }
    
    // MARK: - Encryption Methods
    
    /// Encrypt data
    /// - Parameter data: Data to encrypt
    /// - Returns: Encrypted data
    private func encryptData(_ data: Data) throws -> Data {
        // In a real app, this would use a proper encryption key from a secure storage
        // For demo purposes, we're using a hardcoded key (don't do this in production!)
        let key = SymmetricKey(size: .bits256)
        
        // Use AES-GCM for authenticated encryption
        let sealedBox = try AES.GCM.seal(data, using: key)
        
        return sealedBox.combined!
    }
    
    /// Decrypt data
    /// - Parameter data: Data to decrypt
    /// - Returns: Decrypted data
    private func decryptData(_ data: Data) throws -> Data {
        // In a real app, this would use a proper encryption key from a secure storage
        // For demo purposes, we're using a hardcoded key (don't do this in production!)
        let key = SymmetricKey(size: .bits256)
        
        // Use AES-GCM for authenticated decryption
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
