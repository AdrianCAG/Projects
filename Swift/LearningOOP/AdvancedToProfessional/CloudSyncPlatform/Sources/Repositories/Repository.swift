import Foundation
import RxSwift

/// Generic Repository Protocol
/// Implements the Repository Pattern for data access abstraction
protocol Repository<T> {
    associatedtype T
    
    /// Get all items
    /// - Returns: Observable sequence of items
    func getAll() -> Observable<[T]>
    
    /// Get item by ID
    /// - Parameter id: Item ID
    /// - Returns: Observable with optional item
    func getById(_ id: String) -> Observable<T?>
    
    /// Create a new item
    /// - Parameter item: Item to create
    /// - Returns: Observable with created item
    func create(_ item: T) -> Observable<T>
    
    /// Update an existing item
    /// - Parameter item: Item to update
    /// - Returns: Observable with updated item
    func update(_ item: T) -> Observable<T>
    
    /// Delete an item
    /// - Parameter id: ID of item to delete
    /// - Returns: Observable with completion or error
    func delete(_ id: String) -> Observable<Void>
    
    /// Search for items
    /// - Parameter query: Search query
    /// - Returns: Observable sequence of matching items
    func search(_ query: String) -> Observable<[T]>
}

/// File Repository Protocol
protocol FileRepository: Repository where T == SyncFile {
    /// Get files in a specific path
    /// - Parameter path: Directory path
    /// - Returns: Observable sequence of files
    func getFilesInPath(_ path: String) -> Observable<[SyncFile]>
    
    /// Get starred files
    /// - Returns: Observable sequence of starred files
    func getStarredFiles() -> Observable<[SyncFile]>
    
    /// Get recently modified files
    /// - Parameter limit: Maximum number of files to return
    /// - Returns: Observable sequence of recently modified files
    func getRecentlyModified(limit: Int) -> Observable<[SyncFile]>
    
    /// Get files pending synchronization
    /// - Returns: Observable sequence of pending files
    func getPendingSyncFiles() -> Observable<[SyncFile]>
    
    /// Get files with sync errors
    /// - Returns: Observable sequence of files with errors
    func getFilesWithErrors() -> Observable<[SyncFile]>
    
    /// Update sync status
    /// - Parameters:
    ///   - id: File ID
    ///   - status: New sync status
    /// - Returns: Observable with updated file
    func updateSyncStatus(id: String, status: SyncStatus) -> Observable<SyncFile>
    
    /// Get file content
    /// - Parameter id: File ID
    /// - Returns: Observable with file data
    func getFileContent(id: String) -> Observable<Data>
    
    /// Save file content
    /// - Parameters:
    ///   - id: File ID
    ///   - data: File data
    /// - Returns: Observable with updated file
    func saveFileContent(id: String, data: Data) -> Observable<SyncFile>
}

/// User Repository Protocol
protocol UserRepository: Repository where T == User {
    /// Get current user
    /// - Returns: Observable with current user
    func getCurrentUser() -> Observable<User?>
    
    /// Authenticate user
    /// - Parameters:
    ///   - username: Username
    ///   - password: Password
    /// - Returns: Observable with authenticated user
    func authenticate(username: String, password: String) -> Observable<User>
    
    /// Sign out current user
    /// - Returns: Observable with completion or error
    func signOut() -> Observable<Void>
    
    /// Update user preferences
    /// - Parameter preferences: New preferences
    /// - Returns: Observable with updated user
    func updatePreferences(preferences: UserPreferences) -> Observable<User>
    
    /// Update user storage usage
    /// - Parameter usedStorage: New used storage value
    /// - Returns: Observable with updated user
    func updateStorageUsage(usedStorage: Int64) -> Observable<User>
}

/// Sharing Repository Protocol
protocol SharingRepository {
    /// Share a file with users
    /// - Parameters:
    ///   - fileId: File ID
    ///   - userIds: User IDs to share with
    ///   - permission: Permission level
    /// - Returns: Observable with sharing result
    func shareFile(fileId: String, userIds: [String], permission: SharingPermission) -> Observable<SharingResult>
    
    /// Get users with access to a file
    /// - Parameter fileId: File ID
    /// - Returns: Observable sequence of sharing entries
    func getUsersWithAccess(fileId: String) -> Observable<[SharingEntry]>
    
    /// Get files shared with current user
    /// - Returns: Observable sequence of sharing entries
    func getFilesSharedWithMe() -> Observable<[SharingEntry]>
    
    /// Remove sharing for a file
    /// - Parameters:
    ///   - fileId: File ID
    ///   - userId: User ID to remove sharing for
    /// - Returns: Observable with completion or error
    func removeSharing(fileId: String, userId: String) -> Observable<Void>
    
    /// Update sharing permission
    /// - Parameters:
    ///   - fileId: File ID
    ///   - userId: User ID
    ///   - permission: New permission level
    /// - Returns: Observable with updated sharing entry
    func updatePermission(fileId: String, userId: String, permission: SharingPermission) -> Observable<SharingEntry>
}

/// Sharing permission level
enum SharingPermission: String, Codable {
    case view
    case edit
    case owner
}

/// Sharing entry
struct SharingEntry: Codable, Identifiable, Equatable {
    /// Unique identifier
    let id: String
    
    /// File ID
    let fileId: String
    
    /// User ID
    let userId: String
    
    /// Permission level
    let permission: SharingPermission
    
    /// When sharing was created
    let createdAt: Date
    
    /// User who created the sharing
    let createdBy: String
}

/// Sharing result
struct SharingResult: Codable, Equatable {
    /// Successful sharing entries
    let successful: [SharingEntry]
    
    /// Failed sharing attempts
    let failed: [FailedSharing]
}

/// Failed sharing attempt
struct FailedSharing: Codable, Equatable {
    /// User ID
    let userId: String
    
    /// Error message
    let error: String
}
