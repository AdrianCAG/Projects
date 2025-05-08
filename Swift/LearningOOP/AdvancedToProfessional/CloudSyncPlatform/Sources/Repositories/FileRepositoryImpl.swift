import Foundation
import RxSwift
import RealmSwift
import Logging

/// File Repository Implementation
class FileRepositoryImpl: FileRepository {
    // MARK: - Properties
    
    private let logger = Logger(label: "com.cloudsync.repository.file")
    private let storageManager = StorageManager.shared
    private let realm: Realm
    
    // MARK: - Initialization
    
    init() throws {
        // Configure Realm
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = 1
        config.deleteRealmIfMigrationNeeded = true // For development only
        
        // Open Realm
        do {
            self.realm = try Realm(configuration: config)
            logger.info("FileRepositoryImpl initialized")
        } catch {
            logger.error("Failed to initialize Realm: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Repository Protocol Methods
    
    func getAll() -> Observable<[SyncFile]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            let results = self.realm.objects(RealmSyncFile.self).filter("isDeleted == false")
            let files = Array(results).map { $0.toModel() }
            
            observer.onNext(files)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func getById(_ id: String) -> Observable<SyncFile?> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            if let realmFile = self.realm.object(ofType: RealmSyncFile.self, forPrimaryKey: id) {
                observer.onNext(realmFile.toModel())
            } else {
                observer.onNext(nil)
            }
            
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func create(_ item: SyncFile) -> Observable<SyncFile> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            do {
                let realmFile = RealmSyncFile(from: item)
                
                try self.realm.write {
                    self.realm.add(realmFile)
                }
                
                self.logger.info("Created file: \(item.name)")
                observer.onNext(item)
                observer.onCompleted()
            } catch {
                self.logger.error("Failed to create file: \(error.localizedDescription)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func update(_ item: SyncFile) -> Observable<SyncFile> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            do {
                if let existingFile = self.realm.object(ofType: RealmSyncFile.self, forPrimaryKey: item.id.uuidString) {
                    try self.realm.write {
                        existingFile.update(from: item)
                    }
                    
                    self.logger.info("Updated file: \(item.name)")
                    observer.onNext(item)
                    observer.onCompleted()
                } else {
                    let error = NSError(domain: "com.cloudsync.repository", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(item.id)"])
                    self.logger.error("File not found for update: \(item.id)")
                    observer.onError(error)
                }
            } catch {
                self.logger.error("Failed to update file: \(error.localizedDescription)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func delete(_ id: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            do {
                if let file = self.realm.object(ofType: RealmSyncFile.self, forPrimaryKey: id) {
                    try self.realm.write {
                        // Soft delete
                        file.isDeleted = true
                    }
                    
                    self.logger.info("Deleted file: \(id)")
                    observer.onNext(())
                    observer.onCompleted()
                } else {
                    let error = NSError(domain: "com.cloudsync.repository", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(id)"])
                    self.logger.error("File not found for deletion: \(id)")
                    observer.onError(error)
                }
            } catch {
                self.logger.error("Failed to delete file: \(error.localizedDescription)")
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func search(_ query: String) -> Observable<[SyncFile]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            let results = self.realm.objects(RealmSyncFile.self)
                .filter("isDeleted == false AND (name CONTAINS[c] %@ OR path CONTAINS[c] %@)", query, query)
            
            let files = Array(results).map { $0.toModel() }
            
            observer.onNext(files)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    // MARK: - FileRepository Protocol Methods
    
    func getFilesInPath(_ path: String) -> Observable<[SyncFile]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            let results = self.realm.objects(RealmSyncFile.self)
                .filter("isDeleted == false AND path == %@", path)
            
            let files = Array(results).map { $0.toModel() }
            
            observer.onNext(files)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func getStarredFiles() -> Observable<[SyncFile]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            let results = self.realm.objects(RealmSyncFile.self)
                .filter("isDeleted == false AND isStarred == true")
            
            let files = Array(results).map { $0.toModel() }
            
            observer.onNext(files)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func getRecentlyModified(limit: Int) -> Observable<[SyncFile]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            let results = self.realm.objects(RealmSyncFile.self)
                .filter("isDeleted == false")
                .sorted(byKeyPath: "modifiedAt", ascending: false)
                .prefix(limit)
            
            let files = Array(results).map { $0.toModel() }
            
            observer.onNext(files)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func getPendingSyncFiles() -> Observable<[SyncFile]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            let results = self.realm.objects(RealmSyncFile.self)
                .filter("isDeleted == false AND syncStatusType == %@", SyncStatusType.pending.rawValue)
            
            let files = Array(results).map { $0.toModel() }
            
            observer.onNext(files)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func getFilesWithErrors() -> Observable<[SyncFile]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "com.cloudsync.repository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))
                return Disposables.create()
            }
            
            let results = self.realm.objects(RealmSyncFile.self)
                .filter("isDeleted == false AND syncStatusType == %@", SyncStatusType.error.rawValue)
            
            let files = Array(results).map { $0.toModel() }
            
            observer.onNext(files)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func updateSyncStatus(id: String, status: SyncStatus) -> Observable<SyncFile> {
        return getById(id)
            .flatMap { file -> Observable<SyncFile> in
                guard let file = file else {
                    let error = NSError(domain: "com.cloudsync.repository", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(id)"])
                    return Observable.error(error)
                }
                
                var updatedFile = file
                updatedFile.syncStatus = status
                
                return self.update(updatedFile)
            }
    }
    
    func getFileContent(id: String) -> Observable<Data> {
        return getById(id)
            .flatMap { file -> Observable<Data> in
                guard let file = file else {
                    let error = NSError(domain: "com.cloudsync.repository", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(id)"])
                    return Observable.error(error)
                }
                
                // Get file path
                let filePath = file.path + "/" + file.name
                
                // Load file content
                return self.storageManager.loadFile(from: filePath, decrypt: file.isEncrypted)
            }
    }
    
    func saveFileContent(id: String, data: Data) -> Observable<SyncFile> {
        return getById(id)
            .flatMap { file -> Observable<SyncFile> in
                guard let file = file else {
                    let error = NSError(domain: "com.cloudsync.repository", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(id)"])
                    return Observable.error(error)
                }
                
                // Get file path
                let filePath = file.path + "/" + file.name
                
                // Calculate new hash
                let hash = data.sha256Hash
                
                // Save file content
                return self.storageManager.saveFile(data: data, to: filePath, encrypt: file.isEncrypted)
                    .flatMap { _ -> Observable<SyncFile> in
                        // Update file metadata
                        var updatedFile = file
                        updatedFile.contentHash = hash
                        updatedFile.size = Int64(data.count)
                        updatedFile.modifiedAt = Date()
                        updatedFile.syncStatus = .pending
                        
                        return self.update(updatedFile)
                    }
            }
    }
}

// MARK: - Realm Models

/// Realm Sync File Model
class RealmSyncFile: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var path: String
    @Persisted var size: Int64
    @Persisted var mimeType: String
    @Persisted var createdAt: Date
    @Persisted var modifiedAt: Date
    @Persisted var lastSyncedAt: Date?
    @Persisted var contentHash: String
    @Persisted var version: Int
    @Persisted var ownerId: String
    @Persisted var isShared: Bool
    @Persisted var isStarred: Bool
    @Persisted var isDeleted: Bool
    @Persisted var isEncrypted: Bool
    @Persisted var tags: List<String>
    @Persisted var metadataKeys: List<String>
    @Persisted var metadataValues: List<String>
    
    // Sync status
    @Persisted var syncStatusType: String
    @Persisted var syncStatusProgress: Double
    @Persisted var syncStatusRemoteVersion: Int
    @Persisted var syncStatusErrorMessage: String
    
    /// Initialize from model
    convenience init(from model: SyncFile) {
        self.init()
        
        self.id = model.id.uuidString
        update(from: model)
    }
    
    /// Update from model
    func update(from model: SyncFile) {
        self.name = model.name
        self.path = model.path
        self.size = model.size
        self.mimeType = model.mimeType
        self.createdAt = model.createdAt
        self.modifiedAt = model.modifiedAt
        self.lastSyncedAt = model.lastSyncedAt
        self.contentHash = model.contentHash
        self.version = model.version
        self.ownerId = model.ownerId
        self.isShared = model.isShared
        self.isStarred = model.isStarred
        self.isDeleted = model.isDeleted
        self.isEncrypted = model.isEncrypted
        
        // Update tags
        self.tags.removeAll()
        model.tags.forEach { self.tags.append($0) }
        
        // Update metadata
        self.metadataKeys.removeAll()
        self.metadataValues.removeAll()
        model.metadata.forEach { key, value in
            self.metadataKeys.append(key)
            self.metadataValues.append(value)
        }
        
        // Update sync status
        switch model.syncStatus {
        case .pending:
            self.syncStatusType = SyncStatusType.pending.rawValue
            self.syncStatusProgress = 0
            self.syncStatusRemoteVersion = 0
            self.syncStatusErrorMessage = ""
        case .syncing(let progress):
            self.syncStatusType = SyncStatusType.syncing.rawValue
            self.syncStatusProgress = progress
            self.syncStatusRemoteVersion = 0
            self.syncStatusErrorMessage = ""
        case .synced:
            self.syncStatusType = SyncStatusType.synced.rawValue
            self.syncStatusProgress = 1.0
            self.syncStatusRemoteVersion = 0
            self.syncStatusErrorMessage = ""
        case .conflict(let remoteVersion):
            self.syncStatusType = SyncStatusType.conflict.rawValue
            self.syncStatusProgress = 0
            self.syncStatusRemoteVersion = remoteVersion
            self.syncStatusErrorMessage = ""
        case .error(let message):
            self.syncStatusType = SyncStatusType.error.rawValue
            self.syncStatusProgress = 0
            self.syncStatusRemoteVersion = 0
            self.syncStatusErrorMessage = message
        }
    }
    
    /// Convert to model
    func toModel() -> SyncFile {
        // Convert metadata
        var metadata: [String: String] = [:]
        for i in 0..<min(metadataKeys.count, metadataValues.count) {
            metadata[metadataKeys[i]] = metadataValues[i]
        }
        
        // Convert sync status
        let syncStatus: SyncStatus
        switch SyncStatusType(rawValue: syncStatusType) ?? .pending {
        case .pending:
            syncStatus = .pending
        case .syncing:
            syncStatus = .syncing(progress: syncStatusProgress)
        case .synced:
            syncStatus = .synced
        case .conflict:
            syncStatus = .conflict(remoteVersion: syncStatusRemoteVersion)
        case .error:
            syncStatus = .error(message: syncStatusErrorMessage)
        }
        
        return SyncFile(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            path: path,
            size: size,
            mimeType: mimeType,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            lastSyncedAt: lastSyncedAt,
            contentHash: contentHash,
            version: version,
            ownerId: ownerId,
            isShared: isShared,
            isStarred: isStarred,
            isDeleted: isDeleted,
            isEncrypted: isEncrypted,
            tags: Array(tags),
            metadata: metadata,
            syncStatus: syncStatus
        )
    }
}

/// Sync Status Type for Realm
enum SyncStatusType: String {
    case pending
    case syncing
    case synced
    case conflict
    case error
}
