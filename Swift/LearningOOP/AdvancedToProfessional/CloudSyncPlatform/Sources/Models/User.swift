import Foundation

/// Represents a user in the system
struct User: Codable, Identifiable, Equatable {
    // MARK: - Properties
    
    /// Unique identifier for the user
    let id: String
    
    /// Username
    let username: String
    
    /// Email address
    let email: String
    
    /// Display name
    var displayName: String
    
    /// Profile picture URL
    var profilePictureURL: URL?
    
    /// Account creation date
    let createdAt: Date
    
    /// Last login date
    var lastLoginAt: Date?
    
    /// Storage quota in bytes
    var storageQuota: Int64
    
    /// Used storage in bytes
    var usedStorage: Int64
    
    /// User roles
    var roles: [UserRole]
    
    /// User preferences
    var preferences: UserPreferences
    
    /// Authentication provider
    let authProvider: AuthProvider
    
    /// Account status
    var status: AccountStatus
    
    // MARK: - Computed Properties
    
    /// Remaining storage
    var remainingStorage: Int64 {
        return storageQuota - usedStorage
    }
    
    /// Storage usage percentage
    var storageUsagePercentage: Double {
        guard storageQuota > 0 else { return 0 }
        return Double(usedStorage) / Double(storageQuota) * 100
    }
    
    /// Formatted storage quota
    var formattedStorageQuota: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: storageQuota)
    }
    
    /// Formatted used storage
    var formattedUsedStorage: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: usedStorage)
    }
    
    /// Check if user has a specific role
    func hasRole(_ role: UserRole) -> Bool {
        return roles.contains(role)
    }
    
    /// Check if user is an admin
    var isAdmin: Bool {
        return hasRole(.admin)
    }
}

/// User roles
enum UserRole: String, Codable, CaseIterable {
    case user
    case premium
    case admin
}

/// Authentication provider
enum AuthProvider: String, Codable {
    case email
    case google
    case apple
    case facebook
    case github
}

/// Account status
enum AccountStatus: String, Codable {
    case active
    case suspended
    case deactivated
    case pendingVerification
}

/// User preferences
struct UserPreferences: Codable, Equatable {
    /// Default sync behavior
    var defaultSyncBehavior: SyncBehavior
    
    /// Notification preferences
    var notifications: NotificationPreferences
    
    /// Theme preference
    var theme: ThemePreference
    
    /// Default view mode
    var defaultViewMode: ViewMode
    
    /// Auto-sync enabled
    var autoSyncEnabled: Bool
    
    /// Default sorting option
    var defaultSorting: SortOption
    
    /// Initialize with default values
    init(
        defaultSyncBehavior: SyncBehavior = .automatic,
        notifications: NotificationPreferences = NotificationPreferences(),
        theme: ThemePreference = .system,
        defaultViewMode: ViewMode = .list,
        autoSyncEnabled: Bool = true,
        defaultSorting: SortOption = .nameAscending
    ) {
        self.defaultSyncBehavior = defaultSyncBehavior
        self.notifications = notifications
        self.theme = theme
        self.defaultViewMode = defaultViewMode
        self.autoSyncEnabled = autoSyncEnabled
        self.defaultSorting = defaultSorting
    }
}

/// Sync behavior
enum SyncBehavior: String, Codable {
    case automatic
    case manual
    case scheduled
    case wifiOnly
}

/// Notification preferences
struct NotificationPreferences: Codable, Equatable {
    /// Sync completion notifications
    var syncCompleted: Bool
    
    /// Sync error notifications
    var syncErrors: Bool
    
    /// Sharing notifications
    var sharing: Bool
    
    /// Storage quota notifications
    var storageQuota: Bool
    
    /// Initialize with default values
    init(
        syncCompleted: Bool = true,
        syncErrors: Bool = true,
        sharing: Bool = true,
        storageQuota: Bool = true
    ) {
        self.syncCompleted = syncCompleted
        self.syncErrors = syncErrors
        self.sharing = sharing
        self.storageQuota = storageQuota
    }
}

/// Theme preference
enum ThemePreference: String, Codable {
    case light
    case dark
    case system
}

/// View mode
enum ViewMode: String, Codable {
    case list
    case grid
    case details
}

/// Sort option
enum SortOption: String, Codable {
    case nameAscending
    case nameDescending
    case dateCreatedAscending
    case dateCreatedDescending
    case dateModifiedAscending
    case dateModifiedDescending
    case sizeAscending
    case sizeDescending
}
