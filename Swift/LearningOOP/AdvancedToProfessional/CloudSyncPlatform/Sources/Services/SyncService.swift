import Foundation
import RxSwift

/// Sync Event - Events emitted by the sync service
enum SyncEvent {
    /// Sync started for a file
    case syncStarted(file: SyncFile)
    
    /// Sync progress update
    case syncProgress(file: SyncFile, progress: Double)
    
    /// Sync completed successfully
    case syncCompleted(file: SyncFile, result: SyncResult)
    
    /// Sync failed
    case syncFailed(file: SyncFile, error: Error)
    
    /// Conflict detected
    case conflictDetected(localFile: SyncFile, remoteFile: SyncFile)
    
    /// Batch sync started
    case batchSyncStarted(fileCount: Int)
    
    /// Batch sync completed
    case batchSyncCompleted(results: [SyncResult])
    
    /// Sync queue updated
    case syncQueueUpdated(pendingCount: Int)
}

/// Sync Observer Protocol - Observer Pattern
protocol SyncObserver: AnyObject {
    /// Handle sync events
    /// - Parameter event: Sync event
    func onSyncEvent(_ event: SyncEvent)
}

/// Sync Service Protocol
protocol SyncServiceProtocol {
    /// Add an observer
    /// - Parameter observer: Observer to add
    func addObserver(_ observer: SyncObserver)
    
    /// Remove an observer
    /// - Parameter observer: Observer to remove
    func removeObserver(_ observer: SyncObserver)
    
    /// Synchronize a file
    /// - Parameter file: File to synchronize
    /// - Returns: Observable with sync result
    func synchronize(file: SyncFile) -> Observable<SyncResult>
    
    /// Synchronize multiple files
    /// - Parameter files: Files to synchronize
    /// - Returns: Observable with sync results
    func synchronizeBatch(files: [SyncFile]) -> Observable<[SyncResult]>
    
    /// Synchronize all pending files
    /// - Returns: Observable with sync results
    func synchronizeAllPending() -> Observable<[SyncResult]>
    
    /// Cancel synchronization for a file
    /// - Parameter fileId: File ID
    /// - Returns: Observable with completion or error
    func cancelSync(fileId: String) -> Observable<Void>
    
    /// Resolve a conflict
    /// - Parameters:
    ///   - fileId: File ID
    ///   - resolution: Conflict resolution
    /// - Returns: Observable with resolved file
    func resolveConflict(fileId: String, resolution: ConflictResolution) -> Observable<SyncFile>
    
    /// Get current sync strategy
    /// - Returns: Current sync strategy
    func getCurrentStrategy() -> SyncStrategy
    
    /// Set sync strategy
    /// - Parameter strategyType: Strategy type
    func setStrategy(strategyType: SyncStrategyType)
}

/// Conflict Resolution
enum ConflictResolution {
    /// Keep local version
    case keepLocal
    
    /// Keep remote version
    case keepRemote
    
    /// Keep both versions
    case keepBoth
    
    /// Manual merge
    case manualMerge(mergedFile: SyncFile)
}

/// Sync Service Implementation
class SyncService: SyncServiceProtocol {
    // MARK: - Properties
    
    /// Current sync strategy
    private var currentStrategy: SyncStrategy
    
    /// Observers (weak references)
    private var observers = NSHashTable<AnyObject>.weakObjects()
    
    /// Disposable bag
    private let disposeBag = DisposeBag()
    
    /// Queue of files to sync
    private var syncQueue: [SyncFile] = []
    
    /// Currently syncing files
    private var syncingFiles: Set<String> = []
    
    /// Maximum concurrent syncs
    private let maxConcurrentSyncs: Int
    
    // MARK: - Dependencies
    
    private let fileRepository: any FileRepository
    private let cloudRepository: CloudRepository
    private let strategyFactory: SyncStrategyFactoryProtocol
    
    // MARK: - Initialization
    
    init(
        fileRepository: any FileRepository,
        cloudRepository: CloudRepository,
        strategyFactory: SyncStrategyFactoryProtocol,
        initialStrategyType: SyncStrategyType = .delta,
        maxConcurrentSyncs: Int = 3
    ) {
        self.fileRepository = fileRepository
        self.cloudRepository = cloudRepository
        self.strategyFactory = strategyFactory
        self.maxConcurrentSyncs = maxConcurrentSyncs
        
        // Create initial strategy
        self.currentStrategy = strategyFactory.createStrategy(
            type: initialStrategyType,
            fileRepository: fileRepository,
            cloudRepository: cloudRepository
        )
        
        // Set up periodic sync for pending files
        setupPeriodicSync()
    }
    
    // MARK: - Observer Pattern Methods
    
    func addObserver(_ observer: SyncObserver) {
        observers.add(observer as AnyObject)
    }
    
    func removeObserver(_ observer: SyncObserver) {
        observers.remove(observer as AnyObject)
    }
    
    /// Notify observers of an event
    private func notifyObservers(_ event: SyncEvent) {
        for case let observer as SyncObserver in observers.allObjects {
            observer.onSyncEvent(event)
        }
    }
    
    // MARK: - Sync Methods
    
    func synchronize(file: SyncFile) -> Observable<SyncResult> {
        // Check if file is already being synced
        if syncingFiles.contains(file.id.uuidString) {
            return Observable.error(SyncError.alreadySyncing)
        }
        
        // Check if file needs sync
        if !currentStrategy.needsSync(file: file) {
            return Observable.just(SyncResult.success(
                file: file,
                bytesTransferred: 0,
                timeTaken: 0
            ))
        }
        
        // Notify observers
        notifyObservers(.syncStarted(file: file))
        
        // Add to syncing files
        syncingFiles.insert(file.id.uuidString)
        
        // Perform sync
        return currentStrategy.synchronize(file: file)
            .do(
                onNext: { [weak self] result in
                    guard let self = self else { return }
                    
                    // Remove from syncing files
                    self.syncingFiles.remove(file.id.uuidString)
                    
                    // Notify observers
                    if result.success {
                        self.notifyObservers(.syncCompleted(file: result.file, result: result))
                    } else if let errorMessage = result.errorMessage {
                        self.notifyObservers(.syncFailed(file: result.file, error: SyncError.failed(message: errorMessage)))
                    }
                    
                    // Process next in queue
                    self.processNextInQueue()
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    
                    // Remove from syncing files
                    self.syncingFiles.remove(file.id.uuidString)
                    
                    // Notify observers
                    self.notifyObservers(.syncFailed(file: file, error: error))
                    
                    // Process next in queue
                    self.processNextInQueue()
                }
            )
    }
    
    func synchronizeBatch(files: [SyncFile]) -> Observable<[SyncResult]> {
        guard !files.isEmpty else {
            return Observable.just([])
        }
        
        // Notify batch start
        notifyObservers(.batchSyncStarted(fileCount: files.count))
        
        // Add files to queue
        addToQueue(files: files)
        
        // Create an observable that completes when all files are synced
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            // Track results
            var results: [SyncResult] = []
            var completedCount = 0
            
            // Process files in queue
            self.processQueue()
            
            // Set up observer to collect results
            let syncObserver = SyncResultCollector(
                expectedCount: files.count,
                onResult: { result in
                    results.append(result)
                    completedCount += 1
                    
                    // Check if all files are processed
                    if completedCount == files.count {
                        observer.onNext(results)
                        observer.onCompleted()
                        
                        // Notify batch completion
                        self.notifyObservers(.batchSyncCompleted(results: results))
                    }
                }
            )
            
            // Add observer
            self.addObserver(syncObserver)
            
            return Disposables.create {
                self.removeObserver(syncObserver)
            }
        }
    }
    
    func synchronizeAllPending() -> Observable<[SyncResult]> {
        return fileRepository.getPendingSyncFiles()
            .flatMap { [weak self] files -> Observable<[SyncResult]> in
                guard let self = self else { return Observable.just([]) }
                return self.synchronizeBatch(files: files)
            }
    }
    
    func cancelSync(fileId: String) -> Observable<Void> {
        // Remove from queue if present
        syncQueue.removeAll { $0.id.uuidString == fileId }
        
        // If currently syncing, we can't cancel (would need more complex implementation)
        if syncingFiles.contains(fileId) {
            return Observable.error(SyncError.cannotCancel)
        }
        
        // Notify queue update
        notifyObservers(.syncQueueUpdated(pendingCount: syncQueue.count))
        
        return Observable.just(())
    }
    
    func resolveConflict(fileId: String, resolution: ConflictResolution) -> Observable<SyncFile> {
        // Get the file
        return fileRepository.getById(fileId)
            .flatMap { file -> Observable<SyncFile> in
                guard let file = file else {
                    return Observable.error(SyncError.fileNotFound)
                }
                
                // Check if file has conflict
                guard case .conflict(let remoteVersion) = file.syncStatus else {
                    return Observable.error(SyncError.noConflict)
                }
                
                // Get remote file
                return self.cloudRepository.getFileMetadata(file: file)
                    .flatMap { remoteFile -> Observable<SyncFile> in
                        switch resolution {
                        case .keepLocal:
                            // Keep local version
                            return self.synchronize(file: file)
                                .map { $0.file }
                        
                        case .keepRemote:
                            // Keep remote version
                            return self.cloudRepository.downloadFile(file: remoteFile)
                                .flatMap { data in
                                    return self.fileRepository.saveFileContent(id: fileId, data: data)
                                }
                        
                        case .keepBoth:
                            // Keep both - create a copy of the file
                            let newName = self.generateConflictName(file.name)
                            var localCopy = file
                            localCopy.name = newName
                            localCopy.id = UUID() // New ID for the copy
                            
                            return self.fileRepository.create(localCopy)
                                .flatMap { _ -> Observable<SyncFile> in
                                    // Download remote version to replace original
                                    return self.cloudRepository.downloadFile(file: remoteFile)
                                        .flatMap { data in
                                            return self.fileRepository.saveFileContent(id: fileId, data: data)
                                        }
                                }
                        
                        case .manualMerge(let mergedFile):
                            // Use manually merged file
                            return self.fileRepository.update(mergedFile)
                                .flatMap { file -> Observable<SyncFile> in
                                    return self.synchronize(file: file)
                                        .map { $0.file }
                                }
                        }
                    }
            }
    }
    
    func getCurrentStrategy() -> SyncStrategy {
        return currentStrategy
    }
    
    func setStrategy(strategyType: SyncStrategyType) {
        currentStrategy = strategyFactory.createStrategy(
            type: strategyType,
            fileRepository: fileRepository,
            cloudRepository: cloudRepository
        )
    }
    
    // MARK: - Private Methods
    
    /// Set up periodic sync for pending files
    private func setupPeriodicSync() {
        // Check for pending files every minute
        Observable<Int>.interval(.seconds(60), scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<[SyncFile]> in
                guard let self = self else { return Observable.just([]) }
                return self.fileRepository.getPendingSyncFiles()
            }
            .subscribe(onNext: { [weak self] files in
                guard let self = self else { return }
                
                // Add files to queue
                self.addToQueue(files: files)
            })
            .disposed(by: disposeBag)
    }
    
    /// Add files to sync queue
    private func addToQueue(files: [SyncFile]) {
        // Filter out files already in queue or currently syncing
        let newFiles = files.filter { file in
            let fileId = file.id.uuidString
            return !syncQueue.contains(where: { $0.id.uuidString == fileId }) && !syncingFiles.contains(fileId)
        }
        
        // Add to queue
        syncQueue.append(contentsOf: newFiles)
        
        // Notify queue update
        notifyObservers(.syncQueueUpdated(pendingCount: syncQueue.count))
        
        // Process queue
        processQueue()
    }
    
    /// Process sync queue
    private func processQueue() {
        // Process as many files as allowed by maxConcurrentSyncs
        while syncingFiles.count < maxConcurrentSyncs && !syncQueue.isEmpty {
            let file = syncQueue.removeFirst()
            
            // Synchronize file
            synchronize(file: file)
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    /// Process next file in queue
    private func processNextInQueue() {
        // Check if we can process more files
        if syncingFiles.count < maxConcurrentSyncs && !syncQueue.isEmpty {
            let file = syncQueue.removeFirst()
            
            // Notify queue update
            notifyObservers(.syncQueueUpdated(pendingCount: syncQueue.count))
            
            // Synchronize file
            synchronize(file: file)
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    /// Generate a name for a conflict copy
    private func generateConflictName(_ originalName: String) -> String {
        let fileExtension = URL(fileURLWithPath: originalName).pathExtension
        let baseName = URL(fileURLWithPath: originalName).deletingPathExtension().lastPathComponent
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let dateString = formatter.string(from: Date())
        
        if fileExtension.isEmpty {
            return "\(baseName) (conflict \(dateString))"
        } else {
            return "\(baseName) (conflict \(dateString)).\(fileExtension)"
        }
    }
}

/// Sync Error
enum SyncError: Error, LocalizedError {
    case fileNotFound
    case alreadySyncing
    case cannotCancel
    case noConflict
    case failed(message: String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "File not found"
        case .alreadySyncing:
            return "File is already being synchronized"
        case .cannotCancel:
            return "Cannot cancel ongoing synchronization"
        case .noConflict:
            return "No conflict to resolve"
        case .failed(let message):
            return "Synchronization failed: \(message)"
        }
    }
}

/// Helper class to collect sync results
private class SyncResultCollector: SyncObserver {
    // MARK: - Properties
    
    private let expectedCount: Int
    private let onResult: (SyncResult) -> Void
    
    // MARK: - Initialization
    
    init(expectedCount: Int, onResult: @escaping (SyncResult) -> Void) {
        self.expectedCount = expectedCount
        self.onResult = onResult
    }
    
    // MARK: - SyncObserver Methods
    
    func onSyncEvent(_ event: SyncEvent) {
        switch event {
        case .syncCompleted(_, let result):
            onResult(result)
        case .syncFailed(let file, let error):
            onResult(SyncResult.failure(file: file, error: error.localizedDescription))
        default:
            break
        }
    }
}
