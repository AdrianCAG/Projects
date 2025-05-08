import Foundation

/// Represents a file in the cloud sync system
struct SyncFile: Codable, Identifiable, Equatable {
    // MARK: - Properties
    
    /// Unique identifier for the file
    var id: UUID
    
    /// Name of the file
    var name: String
    
    /// Path to the file
    var path: String
    
    /// Size of the file in bytes
    var size: Int64
    
    /// MIME type of the file
    var mimeType: String
    
    /// Creation date
    let createdAt: Date
    
    /// Last modification date
    var modifiedAt: Date
    
    /// Last sync date
    var lastSyncedAt: Date?
    
    /// MD5 hash of the file content
    var contentHash: String
    
    /// Version of the file
    var version: Int
    
    /// Owner of the file
    var ownerId: String
    
    /// Indicates if the file is shared
    var isShared: Bool
    
    /// Indicates if the file is starred/favorited
    var isStarred: Bool
    
    /// Indicates if the file is deleted (for soft delete)
    var isDeleted: Bool
    
    /// Indicates if the file is encrypted
    var isEncrypted: Bool
    
    /// Tags associated with the file
    var tags: [String]
    
    /// Custom metadata
    var metadata: [String: String]
    
    /// Sync status of the file
    var syncStatus: SyncStatus
    
    // MARK: - Computed Properties
    
    /// File extension
    var fileExtension: String {
        return URL(fileURLWithPath: name).pathExtension
    }
    
    /// Formatted file size
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    /// Local URL for the file
    var localURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(path).appendingPathComponent(name)
    }
    
    // MARK: - Initialization
    
    /// Initialize a new SyncFile
    /// - Parameters:
    ///   - id: Unique identifier (defaults to a new UUID)
    ///   - name: File name
    ///   - path: File path
    ///   - size: File size in bytes
    ///   - mimeType: MIME type
    ///   - createdAt: Creation date (defaults to now)
    ///   - modifiedAt: Modification date (defaults to now)
    ///   - lastSyncedAt: Last sync date (optional)
    ///   - contentHash: MD5 hash of content
    ///   - version: File version (defaults to 1)
    ///   - ownerId: Owner ID
    ///   - isShared: Whether file is shared (defaults to false)
    ///   - isStarred: Whether file is starred (defaults to false)
    ///   - isDeleted: Whether file is deleted (defaults to false)
    ///   - isEncrypted: Whether file is encrypted (defaults to false)
    ///   - tags: Tags (defaults to empty array)
    ///   - metadata: Custom metadata (defaults to empty dictionary)
    ///   - syncStatus: Sync status (defaults to .pending)
    init(
        id: UUID = UUID(),
        name: String,
        path: String,
        size: Int64,
        mimeType: String,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        lastSyncedAt: Date? = nil,
        contentHash: String,
        version: Int = 1,
        ownerId: String,
        isShared: Bool = false,
        isStarred: Bool = false,
        isDeleted: Bool = false,
        isEncrypted: Bool = false,
        tags: [String] = [],
        metadata: [String: String] = [:],
        syncStatus: SyncStatus = .pending
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.size = size
        self.mimeType = mimeType
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.lastSyncedAt = lastSyncedAt
        self.contentHash = contentHash
        self.version = version
        self.ownerId = ownerId
        self.isShared = isShared
        self.isStarred = isStarred
        self.isDeleted = isDeleted
        self.isEncrypted = isEncrypted
        self.tags = tags
        self.metadata = metadata
        self.syncStatus = syncStatus
    }
    
    // MARK: - Methods
    
    /// Create a new version of the file
    /// - Returns: A new SyncFile with incremented version
    func createNewVersion(withHash hash: String, size: Int64) -> SyncFile {
        var newFile = self
        newFile.version += 1
        newFile.modifiedAt = Date()
        newFile.contentHash = hash
        newFile.size = size
        newFile.syncStatus = .pending
        return newFile
    }
    
    /// Mark file as synced
    /// - Returns: Updated SyncFile
    func markAsSynced() -> SyncFile {
        var updatedFile = self
        updatedFile.lastSyncedAt = Date()
        updatedFile.syncStatus = .synced
        return updatedFile
    }
    
    /// Mark file with error
    /// - Parameter error: Error message
    /// - Returns: Updated SyncFile
    func markWithError(_ error: String) -> SyncFile {
        var updatedFile = self
        updatedFile.syncStatus = .error(message: error)
        return updatedFile
    }
}

/// Enum representing the sync status of a file
enum SyncStatus: Equatable, Codable {
    /// File is pending synchronization
    case pending
    
    /// File is currently syncing
    case syncing(progress: Double)
    
    /// File is synced
    case synced
    
    /// File has a conflict
    case conflict(remoteVersion: Int)
    
    /// File sync failed with error
    case error(message: String)
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case type, progress, remoteVersion, message
    }
    
    private enum StatusType: String, Codable {
        case pending, syncing, synced, conflict, error
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .pending:
            try container.encode(StatusType.pending, forKey: .type)
        case .syncing(let progress):
            try container.encode(StatusType.syncing, forKey: .type)
            try container.encode(progress, forKey: .progress)
        case .synced:
            try container.encode(StatusType.synced, forKey: .type)
        case .conflict(let remoteVersion):
            try container.encode(StatusType.conflict, forKey: .type)
            try container.encode(remoteVersion, forKey: .remoteVersion)
        case .error(let message):
            try container.encode(StatusType.error, forKey: .type)
            try container.encode(message, forKey: .message)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(StatusType.self, forKey: .type)
        
        switch type {
        case .pending:
            self = .pending
        case .syncing:
            let progress = try container.decode(Double.self, forKey: .progress)
            self = .syncing(progress: progress)
        case .synced:
            self = .synced
        case .conflict:
            let remoteVersion = try container.decode(Int.self, forKey: .remoteVersion)
            self = .conflict(remoteVersion: remoteVersion)
        case .error:
            let message = try container.decode(String.self, forKey: .message)
            self = .error(message: message)
        }
    }
}
