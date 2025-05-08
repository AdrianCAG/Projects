import Foundation
import RxSwift

/// Sync Strategy Protocol - Strategy Pattern
protocol SyncStrategy {
    /// Get the name of the strategy
    var name: String { get }
    
    /// Get the description of the strategy
    var description: String { get }
    
    /// Synchronize a file
    /// - Parameter file: File to synchronize
    /// - Returns: Observable with sync result
    func synchronize(file: SyncFile) -> Observable<SyncResult>
    
    /// Check if a file needs synchronization
    /// - Parameter file: File to check
    /// - Returns: True if file needs synchronization
    func needsSync(file: SyncFile) -> Bool
    
    /// Resolve a conflict
    /// - Parameters:
    ///   - localFile: Local file version
    ///   - remoteFile: Remote file version
    /// - Returns: Observable with resolved file
    func resolveConflict(localFile: SyncFile, remoteFile: SyncFile) -> Observable<SyncFile>
}

/// Sync Result
struct SyncResult {
    /// Synchronized file
    let file: SyncFile
    
    /// Success flag
    let success: Bool
    
    /// Error message if failed
    let errorMessage: String?
    
    /// Bytes transferred
    let bytesTransferred: Int64
    
    /// Time taken in seconds
    let timeTaken: TimeInterval
    
    /// Create a success result
    /// - Parameters:
    ///   - file: Synchronized file
    ///   - bytesTransferred: Bytes transferred
    ///   - timeTaken: Time taken
    /// - Returns: Success result
    static func success(file: SyncFile, bytesTransferred: Int64, timeTaken: TimeInterval) -> SyncResult {
        return SyncResult(
            file: file,
            success: true,
            errorMessage: nil,
            bytesTransferred: bytesTransferred,
            timeTaken: timeTaken
        )
    }
    
    /// Create a failure result
    /// - Parameters:
    ///   - file: File that failed to sync
    ///   - error: Error message
    /// - Returns: Failure result
    static func failure(file: SyncFile, error: String) -> SyncResult {
        return SyncResult(
            file: file,
            success: false,
            errorMessage: error,
            bytesTransferred: 0,
            timeTaken: 0
        )
    }
}

/// Full Sync Strategy
class FullSyncStrategy: SyncStrategy {
    // MARK: - Properties
    
    var name: String {
        return "Full Sync"
    }
    
    var description: String {
        return "Synchronizes the entire file content, regardless of changes"
    }
    
    // MARK: - Dependencies
    
    private let fileRepository: any FileRepository
    private let cloudRepository: CloudRepository
    
    // MARK: - Initialization
    
    init(fileRepository: any FileRepository, cloudRepository: CloudRepository) {
        self.fileRepository = fileRepository
        self.cloudRepository = cloudRepository
    }
    
    // MARK: - SyncStrategy Methods
    
    func synchronize(file: SyncFile) -> Observable<SyncResult> {
        let startTime = Date()
        
        // Check if file is already being synced
        if case .syncing = file.syncStatus {
            return Observable.just(SyncResult.failure(file: file, error: "File is already being synced"))
        }
        
        // Update status to syncing
        let updatedFile = file.markWithStatus(.syncing(progress: 0.0))
        
        return fileRepository.update(updatedFile)
            .flatMap { file -> Observable<(SyncFile, Data)> in
                // Get file content
                return self.fileRepository.getFileContent(id: file.id.uuidString)
                    .map { (file, $0) }
            }
            .flatMap { file, data -> Observable<SyncFile> in
                // Upload to cloud
                return self.cloudRepository.uploadFile(file: file, data: data, isDelta: false)
                    .map { _ in file }
            }
            .flatMap { file -> Observable<SyncFile> in
                // Mark as synced
                let syncedFile = file.markAsSynced()
                return self.fileRepository.update(syncedFile)
            }
            .map { file -> SyncResult in
                let timeTaken = Date().timeIntervalSince(startTime)
                return SyncResult.success(file: file, bytesTransferred: file.size, timeTaken: timeTaken)
            }
            .catch { error in
                // Handle error
                let errorFile = file.markWithError(error.localizedDescription)
                return self.fileRepository.update(errorFile)
                    .map { SyncResult.failure(file: $0, error: error.localizedDescription) }
            }
    }
    
    func needsSync(file: SyncFile) -> Bool {
        // Full sync strategy always syncs if not already synced
        if case .synced = file.syncStatus {
            return false
        }
        return true
    }
    
    func resolveConflict(localFile: SyncFile, remoteFile: SyncFile) -> Observable<SyncFile> {
        // In full sync, we always prefer the latest modified version
        if localFile.modifiedAt > remoteFile.modifiedAt {
            return Observable.just(localFile)
        } else {
            return Observable.just(remoteFile)
        }
    }
}

/// Delta Sync Strategy
class DeltaSyncStrategy: SyncStrategy {
    // MARK: - Properties
    
    var name: String {
        return "Delta Sync"
    }
    
    var description: String {
        return "Synchronizes only the changes between versions, saving bandwidth"
    }
    
    // MARK: - Dependencies
    
    private let fileRepository: any FileRepository
    private let cloudRepository: CloudRepository
    private let deltaGenerator: DeltaGenerator // From DeltaGenerator.swift
    
    // MARK: - Initialization
    
    init(fileRepository: any FileRepository, cloudRepository: CloudRepository, deltaGenerator: DeltaGenerator) {
        self.fileRepository = fileRepository
        self.cloudRepository = cloudRepository
        self.deltaGenerator = deltaGenerator
    }
    
    // MARK: - SyncStrategy Methods
    
    func synchronize(file: SyncFile) -> Observable<SyncResult> {
        let startTime = Date()
        
        // Check if file is already being synced
        if case .syncing = file.syncStatus {
            return Observable.just(SyncResult.failure(file: file, error: "File is already being synced"))
        }
        
        // Update status to syncing
        let updatedFile = file.markWithStatus(.syncing(progress: 0.0))
        
        return fileRepository.update(updatedFile)
            .flatMap { file -> Observable<(SyncFile, Data, Data?)> in
                // Get file content
                return self.fileRepository.getFileContent(id: file.id.uuidString)
                    .flatMap { localData -> Observable<(SyncFile, Data, Data?)> in
                        // Get remote file if it exists
                        return self.cloudRepository.getFileContent(file: file)
                            .map { (file, localData, $0) }
                            .catchAndReturn((file, localData, nil as Data?))
                    }
            }
            .flatMap { file, localData, remoteData -> Observable<(SyncFile, Data, Int64)> in
                // Generate delta if remote file exists
                if let remoteData = remoteData {
                    return self.deltaGenerator.generateDelta(oldData: remoteData, newData: localData)
                        .map { (file, $0, Int64($0.count)) }
                } else {
                    // No remote file, upload full content
                    return Observable.just((file, localData, file.size))
                }
            }
            .flatMap { file, deltaData, bytesTransferred -> Observable<SyncFile> in
                // Upload delta or full file
                return self.cloudRepository.uploadFile(file: file, data: deltaData, isDelta: bytesTransferred < file.size)
                    .map { _ in file }
            }
            .flatMap { file -> Observable<SyncFile> in
                // Mark as synced
                let syncedFile = file.markAsSynced()
                return self.fileRepository.update(syncedFile)
            }
            .map { file -> SyncResult in
                let timeTaken = Date().timeIntervalSince(startTime)
                // We don't know exact bytes transferred here, would need to track in actual implementation
                return SyncResult.success(file: file, bytesTransferred: file.size / 2, timeTaken: timeTaken)
            }
            .catch { error in
                // Handle error
                let errorFile = file.markWithError(error.localizedDescription)
                return self.fileRepository.update(errorFile)
                    .map { SyncResult.failure(file: $0, error: error.localizedDescription) }
            }
    }
    
    func needsSync(file: SyncFile) -> Bool {
        // Delta sync only syncs if file has changes
        if case .synced = file.syncStatus {
            return false
        }
        
        // Check if content hash has changed since last sync
        // This would require comparing with remote hash in real implementation
        return true
    }
    
    func resolveConflict(localFile: SyncFile, remoteFile: SyncFile) -> Observable<SyncFile> {
        // In delta sync, we try to merge changes if possible
        if localFile.contentHash == remoteFile.contentHash {
            // Same content, take the one with more metadata
            if localFile.metadata.count > remoteFile.metadata.count {
                return Observable.just(localFile)
            } else {
                return Observable.just(remoteFile)
            }
        } else {
            // Different content, we would need a proper merge algorithm
            // For this example, we'll use the latest modified as a simple strategy
            if localFile.modifiedAt > remoteFile.modifiedAt {
                return Observable.just(localFile)
            } else {
                return Observable.just(remoteFile)
            }
        }
    }
}

/// Scheduled Sync Strategy
class ScheduledSyncStrategy: SyncStrategy {
    // MARK: - Properties
    
    var name: String {
        return "Scheduled Sync"
    }
    
    var description: String {
        return "Synchronizes files on a scheduled basis rather than immediately"
    }
    
    // MARK: - Dependencies
    
    private let fileRepository: any FileRepository
    private let cloudRepository: CloudRepository
    private let baseStrategy: SyncStrategy
    private let scheduler: SchedulerType
    
    // MARK: - Initialization
    
    init(
        fileRepository: any FileRepository,
        cloudRepository: CloudRepository,
        baseStrategy: SyncStrategy,
        scheduler: SchedulerType
    ) {
        self.fileRepository = fileRepository
        self.cloudRepository = cloudRepository
        self.baseStrategy = baseStrategy
        self.scheduler = scheduler
    }
    
    /// Convenience initializer that uses FullSyncStrategy as the base strategy
    /// - Parameters:
    ///   - fileRepository: File repository
    ///   - cloudRepository: Cloud repository
    ///   - scheduler: Scheduler to use for delayed execution
    init(
        fileRepository: any FileRepository,
        cloudRepository: CloudRepository,
        scheduler: SchedulerType
    ) {
        self.fileRepository = fileRepository
        self.cloudRepository = cloudRepository
        self.baseStrategy = FullSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository)
        self.scheduler = scheduler
    }
    
    // MARK: - SyncStrategy Methods
    
    func synchronize(file: SyncFile) -> Observable<SyncResult> {
        // Schedule the sync using the base strategy
        return Observable.just(file)
            .delay(.seconds(calculateDelay(for: file)), scheduler: scheduler)
            .flatMap { file in
                return self.baseStrategy.synchronize(file: file)
            }
    }
    
    func needsSync(file: SyncFile) -> Bool {
        return baseStrategy.needsSync(file: file)
    }
    
    func resolveConflict(localFile: SyncFile, remoteFile: SyncFile) -> Observable<SyncFile> {
        return baseStrategy.resolveConflict(localFile: localFile, remoteFile: remoteFile)
    }
    
    // MARK: - Helper Methods
    
    private func calculateDelay(for file: SyncFile) -> Int {
        // Calculate delay based on file size, priority, etc.
        // For this example, we'll use a simple algorithm
        
        // Smaller files get synced sooner
        let sizeDelay = min(Int(file.size / (1024 * 1024)), 60) // Max 60 seconds for size
        
        // Newer files get synced sooner
        let ageInHours = Int(Date().timeIntervalSince(file.modifiedAt) / 3600)
        let ageDelay = min(ageInHours, 30) // Max 30 seconds for age
        
        // Calculate total delay
        return max(5, sizeDelay + ageDelay) // Minimum 5 seconds delay
    }
}

/// Selective Sync Strategy
class SelectiveSyncStrategy: SyncStrategy {
    // MARK: - Properties
    
    var name: String {
        return "Selective Sync"
    }
    
    var description: String {
        return "Synchronizes only files matching specific criteria"
    }
    
    // MARK: - Dependencies
    
    private let fileRepository: any FileRepository
    private let cloudRepository: CloudRepository
    private let baseStrategy: SyncStrategy
    private let filter: (SyncFile) -> Bool
    
    // MARK: - Initialization
    
    init(
        fileRepository: any FileRepository,
        cloudRepository: CloudRepository,
        baseStrategy: SyncStrategy,
        filter: @escaping (SyncFile) -> Bool
    ) {
        self.fileRepository = fileRepository
        self.cloudRepository = cloudRepository
        self.baseStrategy = baseStrategy
        self.filter = filter
    }
    
    /// Convenience initializer that uses FullSyncStrategy as the base strategy
    /// - Parameters:
    ///   - fileRepository: File repository
    ///   - cloudRepository: Cloud repository
    ///   - filter: File filter
    init(
        fileRepository: any FileRepository,
        cloudRepository: CloudRepository,
        filter: @escaping (SyncFile) -> Bool
    ) {
        self.fileRepository = fileRepository
        self.cloudRepository = cloudRepository
        self.baseStrategy = FullSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository)
        self.filter = filter
    }
    
    // MARK: - SyncStrategy Methods
    
    func synchronize(file: SyncFile) -> Observable<SyncResult> {
        // Only sync if file passes the filter
        if filter(file) {
            return baseStrategy.synchronize(file: file)
        } else {
            // Skip this file
            return Observable.just(SyncResult.success(
                file: file,
                bytesTransferred: 0,
                timeTaken: 0
            ))
        }
    }
    
    func needsSync(file: SyncFile) -> Bool {
        return filter(file) && baseStrategy.needsSync(file: file)
    }
    
    func resolveConflict(localFile: SyncFile, remoteFile: SyncFile) -> Observable<SyncFile> {
        return baseStrategy.resolveConflict(localFile: localFile, remoteFile: remoteFile)
    }
}

// Note: DeltaGenerator and CloudRepository protocols are now defined in their respective files
    
    /// List files in a path
    /// - Parameter path: Directory path
    /// - Returns: Observable sequence of files
    func listFiles(path: String) -> Observable<[SyncFile]> {
        // Default implementation returns empty list
        return Observable.just([])
    }

/// Extension to SyncFile for marking with status
extension SyncFile {
    /// Mark file with a specific status
    /// - Parameter status: New status
    /// - Returns: Updated file
    func markWithStatus(_ status: SyncStatus) -> SyncFile {
        var updatedFile = self
        updatedFile.syncStatus = status
        return updatedFile
    }
}

/// Default Sync Strategy Factory - Implementation of the Factory defined in SyncStrategyFactory.swift
class DefaultSyncStrategyFactory {
    // MARK: - Dependencies
    
    private let deltaGenerator: DeltaGenerator // From DeltaGenerator.swift
    private let scheduler: SchedulerType
    
    // MARK: - Initialization
    
    init(deltaGenerator: DeltaGenerator, scheduler: SchedulerType) {
        self.deltaGenerator = deltaGenerator
        self.scheduler = scheduler
    }
    
    // MARK: - Factory Method
    
    func createStrategy(type: SyncStrategyType, fileRepository: any FileRepository, cloudRepository: CloudRepository) -> SyncStrategy {
        switch type {
        case .full:
            return FullSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository)
        case .delta:
            return DeltaSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository, deltaGenerator: deltaGenerator)
        case .scheduled:
            // Use full sync as the base strategy for scheduled sync
            let baseStrategy = FullSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository)
            return ScheduledSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository, baseStrategy: baseStrategy, scheduler: scheduler)
        case .selective:
            // Use delta sync as the base strategy for selective sync
            let baseStrategy = DeltaSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository, deltaGenerator: deltaGenerator)
            // Default filter that includes all files
            let filter: (SyncFile) -> Bool = { _ in true }
            return SelectiveSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository, baseStrategy: baseStrategy, filter: filter)
        }
    }
}
