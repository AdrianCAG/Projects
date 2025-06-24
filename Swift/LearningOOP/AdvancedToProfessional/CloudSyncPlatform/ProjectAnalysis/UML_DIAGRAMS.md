# CloudSyncPlatform UML Diagrams

This document contains comprehensive UML diagrams for the CloudSyncPlatform project, created using Mermaid syntax.

## Table of Contents

1. [Main Class Diagram](#main-class-diagram)
2. [Repository Pattern Diagram](#repository-pattern-diagram)
3. [Strategy Pattern Diagram](#strategy-pattern-diagram)
4. [Observer Pattern Diagram](#observer-pattern-diagram)
5. [File Synchronization Sequence Diagram](#file-synchronization-sequence-diagram)
6. [User Authentication Sequence Diagram](#user-authentication-sequence-diagram)
7. [Component Architecture Diagram](#component-architecture-diagram)
8. [Service Layer Diagram](#service-layer-diagram)
9. [State Diagram - File Sync States](#state-diagram---file-sync-states)
10. [Activity Diagram - Conflict Resolution](#activity-diagram---conflict-resolution)
11. [Database Schema Diagram](#database-schema-diagram)
12. [Deployment Architecture Diagram](#deployment-architecture-diagram)

---

## Main Class Diagram

```mermaid
classDiagram
    class CloudSyncApp {
        -disposeBag: DisposeBag
        -isRunning: Bool
        -logger: Logger
        -ui: ConsoleUI
        -storageManager: StorageManager
        -networkManager: NetworkManager
        -securityManager: SecurityManager
        -configManager: ConfigurationManager
        -fileRepository: FileRepository
        -cloudRepository: CloudRepository
        -syncService: SyncServiceProtocol
        -currentUser: User?
        +init()
        +run(): Void
        +setupDependencies(): Void
        +authenticateUser(): Observable~User~
        +startMainLoop(): Void
        +handleUserInput(): Void
        +shutdown(): Void
    }

    class ConfigurationManager {
        +shared: ConfigurationManager
        -configuration: [String: Any]
        -configPath: String
        +loadConfiguration(): Void
        +getProperty(key: String): Any?
        +setProperty(key: String, value: Any): Void
        +saveConfiguration(): Observable~Void~
        +validateConfiguration(): Bool
    }

    class StorageManager {
        +shared: StorageManager
        -fileManager: FileManager
        -basePath: URL
        -logger: Logger
        +saveFile(data: Data, path: String): Observable~Void~
        +loadFile(path: String): Observable~Data~
        +deleteFile(path: String): Observable~Void~
        +fileExists(path: String): Bool
        +createDirectory(path: String): Observable~Void~
        +listFiles(path: String): Observable~[String]~
        +getFileSize(path: String): Int64
        +getFileChecksum(path: String): String
    }

    class NetworkManager {
        +shared: NetworkManager
        -session: URLSession
        -baseURL: URL
        -authToken: String?
        -logger: Logger
        +request(endpoint: APIEndpoint): Observable~Data~
        +uploadFile(data: Data, endpoint: String): Observable~Void~
        +downloadFile(url: String): Observable~Data~
        +setAuthToken(token: String): Void
        +clearAuthToken(): Void
        -createRequest(endpoint: APIEndpoint): URLRequest
        -handleResponse(data: Data?, response: URLResponse?, error: Error?): Observable~Data~
    }

    class SecurityManager {
        +shared: SecurityManager
        -encryptionKey: SymmetricKey
        -logger: Logger
        +encrypt(data: Data): Data
        +decrypt(data: Data): Data
        +generateKey(): SymmetricKey
        +authenticateUser(credentials: Credentials): Observable~User~
        +hashPassword(password: String): String
        +verifyPassword(password: String, hash: String): Bool
        +generateToken(user: User): String
        +validateToken(token: String): Observable~User~
    }

    class User {
        +id: String
        +email: String
        +name: String
        +preferences: UserPreferences
        +createdAt: Date
        +updatedAt: Date
        +isActive: Bool
        +init(id: String, email: String, name: String)
        +updatePreferences(preferences: UserPreferences): Void
        +toJSON(): [String: Any]
        +fromJSON(json: [String: Any]): User?
    }

    class SyncFile {
        +id: String
        +name: String
        +path: String
        +size: Int64
        +checksum: String
        +lastModified: Date
        +isDeleted: Bool
        +isStarred: Bool
        +userId: String
        +syncStatus: SyncStatus
        +conflictState: ConflictState
        +init(name: String, path: String, size: Int64)
        +updateChecksum(): Void
        +markAsDeleted(): Void
        +markAsStarred(): Void
        +toRealmObject(): RealmSyncFile
    }

    %% Main relationships
    CloudSyncApp --> ConfigurationManager : uses
    CloudSyncApp --> StorageManager : uses
    CloudSyncApp --> NetworkManager : uses
    CloudSyncApp --> SecurityManager : uses
    CloudSyncApp --> User : manages
    StorageManager --> SyncFile : stores
    SecurityManager --> User : authenticates
```

---

## Repository Pattern Diagram

```mermaid
classDiagram
    class Repository~T~ {
        <<interface>>
        +getAll(): Observable~[T]~
        +getById(id: String): Observable~T?~
        +create(item: T): Observable~T~
        +update(item: T): Observable~T~
        +delete(id: String): Observable~Void~
        +search(query: String): Observable~[T]~
    }

    class FileRepository {
        <<interface>>
        +getFilesInPath(path: String): Observable~[SyncFile]~
        +getStarredFiles(): Observable~[SyncFile]~
        +getRecentlyModified(limit: Int): Observable~[SyncFile]~
        +getFilesByUser(userId: String): Observable~[SyncFile]~
        +markAsDeleted(id: String): Observable~Void~
        +updateSyncStatus(id: String, status: SyncStatus): Observable~Void~
        +getConflictedFiles(): Observable~[SyncFile]~
    }

    class CloudRepository {
        <<interface>>
        +uploadFile(file: SyncFile, data: Data, isDelta: Bool): Observable~Void~
        +downloadFile(file: SyncFile): Observable~Data~
        +deleteFile(file: SyncFile): Observable~Void~
        +getFileMetadata(id: String): Observable~SyncFile~
        +listFiles(path: String): Observable~[SyncFile]~
        +shareFile(file: SyncFile, users: [String]): Observable~SharingResult~
        +getSharedFiles(): Observable~[SyncFile]~
    }

    class FileRepositoryImpl {
        -realm: Realm
        -storageManager: StorageManager
        -logger: Logger
        +init(storageManager: StorageManager)
        +getAll(): Observable~[SyncFile]~
        +getById(id: String): Observable~SyncFile?~
        +create(item: SyncFile): Observable~SyncFile~
        +update(item: SyncFile): Observable~SyncFile~
        +delete(id: String): Observable~Void~
        +search(query: String): Observable~[SyncFile]~
        +getFilesInPath(path: String): Observable~[SyncFile]~
        +getStarredFiles(): Observable~[SyncFile]~
        -mapFromRealm(realmFile: RealmSyncFile): SyncFile
        -mapToRealm(file: SyncFile): RealmSyncFile
        -executeTransaction(block: () -> Void): Observable~Void~
    }

    class CloudRepositoryImpl {
        -networkManager: NetworkManager
        -securityManager: SecurityManager
        -logger: Logger
        +init(networkManager: NetworkManager, securityManager: SecurityManager)
        +uploadFile(file: SyncFile, data: Data, isDelta: Bool): Observable~Void~
        +downloadFile(file: SyncFile): Observable~Data~
        +deleteFile(file: SyncFile): Observable~Void~
        +getFileMetadata(id: String): Observable~SyncFile~
        +listFiles(path: String): Observable~[SyncFile]~
        +shareFile(file: SyncFile, users: [String]): Observable~SharingResult~
        -buildUploadRequest(file: SyncFile, data: Data): URLRequest
        -handleUploadResponse(response: Data): Observable~Void~
        -encryptFileData(data: Data): Data
        -decryptFileData(data: Data): Data
    }

    class RealmSyncFile {
        @Persisted id: String
        @Persisted name: String
        @Persisted path: String
        @Persisted size: Int64
        @Persisted checksum: String
        @Persisted lastModified: Date
        @Persisted isDeleted: Bool
        @Persisted isStarred: Bool
        @Persisted userId: String
        @Persisted syncStatusRaw: String
        +syncStatus: SyncStatus
        +toDomainModel(): SyncFile
    }

    %% Inheritance relationships
    FileRepository --|> Repository : extends
    FileRepositoryImpl ..|> FileRepository : implements
    CloudRepositoryImpl ..|> CloudRepository : implements
    Repository~T~ <|.. FileRepository : T = SyncFile

    %% Composition relationships
    FileRepositoryImpl --> RealmSyncFile : uses
    FileRepositoryImpl --> StorageManager : uses
    CloudRepositoryImpl --> NetworkManager : uses
    CloudRepositoryImpl --> SecurityManager : uses

    %% Data relationships
    FileRepository --> SyncFile : manages
    CloudRepository --> SyncFile : manages
    RealmSyncFile --> SyncFile : maps to
```

---

## Strategy Pattern Diagram

```mermaid
classDiagram
    class SyncStrategy {
        <<interface>>
        +name: String
        +sync(file: SyncFile): Observable~SyncResult~
        +canHandle(file: SyncFile): Bool
        +getPriority(): Int
        +getEstimatedTime(file: SyncFile): TimeInterval
    }

    class SyncStrategyFactory {
        <<interface>>
        +createStrategy(type: SyncStrategyType, config: SyncConfig): SyncStrategy
        +getAvailableStrategies(): [SyncStrategyType]
        +getDefaultStrategy(): SyncStrategy
    }

    class DefaultSyncStrategyFactory {
        -fileRepository: FileRepository
        -cloudRepository: CloudRepository
        -deltaGenerator: DeltaGenerator
        -logger: Logger
        +init(fileRepository: FileRepository, cloudRepository: CloudRepository)
        +createStrategy(type: SyncStrategyType, config: SyncConfig): SyncStrategy
        +getAvailableStrategies(): [SyncStrategyType]
        +getDefaultStrategy(): SyncStrategy
        -createFullSyncStrategy(): FullSyncStrategy
        -createDeltaSyncStrategy(): DeltaSyncStrategy
        -createScheduledSyncStrategy(): ScheduledSyncStrategy
        -createSelectiveSyncStrategy(): SelectiveSyncStrategy
    }

    class FullSyncStrategy {
        +name: String
        -fileRepository: FileRepository
        -cloudRepository: CloudRepository
        -logger: Logger
        +init(fileRepository: FileRepository, cloudRepository: CloudRepository)
        +sync(file: SyncFile): Observable~SyncResult~
        +canHandle(file: SyncFile): Bool
        +getPriority(): Int
        +getEstimatedTime(file: SyncFile): TimeInterval
        -performFullUpload(file: SyncFile): Observable~SyncResult~
        -performFullDownload(file: SyncFile): Observable~SyncResult~
        -checkForConflicts(localFile: SyncFile, remoteFile: SyncFile): ConflictState
    }

    class DeltaSyncStrategy {
        +name: String
        -fileRepository: FileRepository
        -cloudRepository: CloudRepository
        -deltaGenerator: DeltaGenerator
        -logger: Logger
        +init(fileRepository: FileRepository, cloudRepository: CloudRepository, deltaGenerator: DeltaGenerator)
        +sync(file: SyncFile): Observable~SyncResult~
        +canHandle(file: SyncFile): Bool
        +getPriority(): Int
        +getEstimatedTime(file: SyncFile): TimeInterval
        -generateDelta(oldFile: SyncFile, newFile: SyncFile): Observable~Data~
        -applyDelta(file: SyncFile, delta: Data): Observable~SyncFile~
        -uploadDelta(file: SyncFile, delta: Data): Observable~Void~
        -downloadDelta(file: SyncFile): Observable~Data~
    }

    class ScheduledSyncStrategy {
        +name: String
        -fileRepository: FileRepository
        -cloudRepository: CloudRepository
        -scheduler: Timer
        -syncQueue: [SyncFile]
        -logger: Logger
        +init(fileRepository: FileRepository, cloudRepository: CloudRepository)
        +sync(file: SyncFile): Observable~SyncResult~
        +canHandle(file: SyncFile): Bool
        +scheduleSync(file: SyncFile, delay: TimeInterval): Void
        +startScheduler(): Void
        +stopScheduler(): Void
        -processSyncQueue(): Void
        -shouldSyncNow(file: SyncFile): Bool
    }

    class SelectiveSyncStrategy {
        +name: String
        -fileRepository: FileRepository
        -cloudRepository: CloudRepository
        -syncRules: [SyncRule]
        -logger: Logger
        +init(fileRepository: FileRepository, cloudRepository: CloudRepository)
        +sync(file: SyncFile): Observable~SyncResult~
        +canHandle(file: SyncFile): Bool
        +addSyncRule(rule: SyncRule): Void
        +removeSyncRule(rule: SyncRule): Void
        -evaluateRules(file: SyncFile): Bool
        -applyFileFilters(file: SyncFile): Bool
    }

    class DeltaGenerator {
        -algorithm: DeltaAlgorithm
        -logger: Logger
        +init(algorithm: DeltaAlgorithm)
        +generateDelta(oldData: Data, newData: Data): Observable~Data~
        +applyDelta(originalData: Data, delta: Data): Observable~Data~
        +getDeltaSize(delta: Data): Int64
        +validateDelta(delta: Data): Bool
        -createBinaryDiff(old: Data, new: Data): Data
        -applyBinaryDiff(original: Data, diff: Data): Data
    }

    class SyncResult {
        +file: SyncFile
        +status: SyncStatus
        +error: Error?
        +bytesTransferred: Int64
        +timeElapsed: TimeInterval
        +strategyUsed: String
        +init(file: SyncFile, status: SyncStatus)
        +isSuccess: Bool
        +hasConflict: Bool
        +getErrorDescription(): String?
    }

    %% Strategy pattern relationships
    SyncStrategy <|.. FullSyncStrategy : implements
    SyncStrategy <|.. DeltaSyncStrategy : implements
    SyncStrategy <|.. ScheduledSyncStrategy : implements
    SyncStrategy <|.. SelectiveSyncStrategy : implements

    %% Factory pattern relationships
    SyncStrategyFactory <|.. DefaultSyncStrategyFactory : implements
    DefaultSyncStrategyFactory --> FullSyncStrategy : creates
    DefaultSyncStrategyFactory --> DeltaSyncStrategy : creates
    DefaultSyncStrategyFactory --> ScheduledSyncStrategy : creates
    DefaultSyncStrategyFactory --> SelectiveSyncStrategy : creates

    %% Dependencies
    DeltaSyncStrategy --> DeltaGenerator : uses
    DefaultSyncStrategyFactory --> DeltaGenerator : uses

    %% Result relationship
    SyncStrategy --> SyncResult : returns
    SyncResult --> SyncFile : contains
```

---

## Observer Pattern Diagram

```mermaid
classDiagram
    class SyncObserver {
        <<interface>>
        +onSyncEvent(event: SyncEvent): Void
        +getObserverId(): String
        +isInterestedIn(event: SyncEvent): Bool
    }

    class SyncEventObserver {
        -observerId: String
        -eventFilters: [SyncEventType]
        -logger: Logger
        +init(observerId: String)
        +onSyncEvent(event: SyncEvent): Void
        +getObserverId(): String
        +isInterestedIn(event: SyncEvent): Bool
        +addEventFilter(eventType: SyncEventType): Void
        +removeEventFilter(eventType: SyncEventType): Void
        -handleSyncStarted(file: SyncFile): Void
        -handleSyncProgress(file: SyncFile, progress: Double): Void
        -handleSyncCompleted(file: SyncFile, result: SyncResult): Void
        -handleSyncFailed(file: SyncFile, error: Error): Void
        -handleConflictDetected(localFile: SyncFile, remoteFile: SyncFile): Void
    }

    class SyncService {
        -observers: [SyncObserver]
        -observerQueue: DispatchQueue
        -fileRepository: FileRepository
        -cloudRepository: CloudRepository
        -strategyFactory: SyncStrategyFactory
        -logger: Logger
        +addObserver(observer: SyncObserver): Void
        +removeObserver(observer: SyncObserver): Void
        +syncFile(file: SyncFile): Observable~SyncResult~
        +syncAll(): Observable~[SyncResult]~
        +batchSync(files: [SyncFile]): Observable~[SyncResult]~
        -notifyObservers(event: SyncEvent): Void
        -executeSync(file: SyncFile, strategy: SyncStrategy): Observable~SyncResult~
        -handleSyncError(file: SyncFile, error: Error): Void
    }

    class ConsoleUIObserver {
        -ui: ConsoleUI
        -progressBars: [String: ProgressBar]
        +init(ui: ConsoleUI)
        +onSyncEvent(event: SyncEvent): Void
        +getObserverId(): String
        +isInterestedIn(event: SyncEvent): Bool
        -updateProgressBar(fileId: String, progress: Double): Void
        -showSyncCompletion(file: SyncFile, result: SyncResult): Void
        -showConflictDialog(localFile: SyncFile, remoteFile: SyncFile): Void
        -displayError(file: SyncFile, error: Error): Void
    }

    class LoggingObserver {
        -logger: Logger
        -logLevel: LogLevel
        +init(logger: Logger, logLevel: LogLevel)
        +onSyncEvent(event: SyncEvent): Void
        +getObserverId(): String
        +isInterestedIn(event: SyncEvent): Bool
        -logEvent(event: SyncEvent, level: LogLevel): Void
        -formatEventMessage(event: SyncEvent): String
        -shouldLog(eventType: SyncEventType): Bool
    }

    class NotificationObserver {
        -notificationCenter: UNUserNotificationCenter
        -userPreferences: UserPreferences
        +init(notificationCenter: UNUserNotificationCenter)
        +onSyncEvent(event: SyncEvent): Void
        +getObserverId(): String
        +isInterestedIn(event: SyncEvent): Bool
        -sendNotification(title: String, body: String, identifier: String): Void
        -shouldNotify(eventType: SyncEventType): Bool
        -createNotificationContent(event: SyncEvent): UNNotificationContent
    }

    class SyncEvent {
        <<enumeration>>
        syncStarted(file: SyncFile)
        syncProgress(file: SyncFile, progress: Double)
        syncCompleted(file: SyncFile, result: SyncResult)
        syncFailed(file: SyncFile, error: Error)
        conflictDetected(localFile: SyncFile, remoteFile: SyncFile)
        batchSyncStarted(fileCount: Int)
        batchSyncCompleted(results: [SyncResult])
        syncQueueUpdated(pendingCount: Int)
        +getEventType(): SyncEventType
        +getTimestamp(): Date
        +getFileId(): String?
        +getDescription(): String
    }

    %% Observer pattern relationships
    SyncObserver <|.. SyncEventObserver : implements
    SyncObserver <|.. ConsoleUIObserver : implements
    SyncObserver <|.. LoggingObserver : implements
    SyncObserver <|.. NotificationObserver : implements

    %% Subject-Observer relationships
    SyncService --> SyncObserver : notifies
    SyncService --> SyncEvent : publishes

    %% Concrete observer dependencies
    ConsoleUIObserver --> ConsoleUI : uses
    LoggingObserver --> Logger : uses
    NotificationObserver --> UNUserNotificationCenter : uses
    NotificationObserver --> UserPreferences : uses

    %% Event relationships
    SyncEvent --> SyncFile : references
    SyncEvent --> SyncResult : references
```

---

## File Synchronization Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant CloudSyncApp
    participant SyncService
    participant SyncStrategy
    participant FileRepository
    participant CloudRepository
    participant NetworkManager
    participant SecurityManager
    participant Observer as SyncObserver

    User->>CloudSyncApp: Request file sync
    CloudSyncApp->>CloudSyncApp: Validate user permissions
    CloudSyncApp->>SyncService: syncFile(file)
    
    SyncService->>Observer: notify(syncStarted)
    Observer->>Observer: Update UI progress
    
    SyncService->>FileRepository: getById(fileId)
    FileRepository->>SyncService: Return local file
    
    SyncService->>CloudRepository: getFileMetadata(fileId)
    CloudRepository->>NetworkManager: GET /files/{id}/metadata
    NetworkManager->>CloudRepository: Return metadata
    CloudRepository->>SyncService: Return remote file info
    
    SyncService->>SyncService: Compare local vs remote versions
    SyncService->>SyncStrategy: Determine sync strategy
    SyncStrategy->>SyncService: Return chosen strategy
    
    alt Local file is newer
        SyncService->>Observer: notify(syncProgress, 25%)
        SyncService->>FileRepository: loadFileData(file)
        FileRepository->>SyncService: Return file data
        
        SyncService->>SecurityManager: encrypt(fileData)
        SecurityManager->>SyncService: Return encrypted data
        
        SyncService->>Observer: notify(syncProgress, 50%)
        SyncService->>CloudRepository: uploadFile(file, encryptedData)
        CloudRepository->>NetworkManager: POST /files/{id}/upload
        NetworkManager->>CloudRepository: Upload success
        
        SyncService->>Observer: notify(syncProgress, 75%)
        SyncService->>FileRepository: updateSyncStatus(file, synced)
        FileRepository->>SyncService: Confirm update
        
    else Remote file is newer
        SyncService->>Observer: notify(syncProgress, 25%)
        SyncService->>CloudRepository: downloadFile(file)
        CloudRepository->>NetworkManager: GET /files/{id}/download
        NetworkManager->>CloudRepository: Return encrypted data
        
        SyncService->>Observer: notify(syncProgress, 50%)
        SyncService->>SecurityManager: decrypt(encryptedData)
        SecurityManager->>SyncService: Return decrypted data
        
        SyncService->>Observer: notify(syncProgress, 75%)
        SyncService->>FileRepository: saveFile(file, data)
        FileRepository->>SyncService: Confirm save
        
    else Conflict detected
        SyncService->>Observer: notify(conflictDetected, localFile, remoteFile)
        Observer->>User: Show conflict resolution dialog
        User->>Observer: Choose resolution strategy
        Observer->>SyncService: Resolution choice
        
        alt User chooses local version
            SyncService->>CloudRepository: uploadFile(localFile)
        else User chooses remote version
            SyncService->>CloudRepository: downloadFile(remoteFile)
        else User chooses merge
            SyncService->>SyncService: Perform merge operation
            SyncService->>CloudRepository: uploadFile(mergedFile)
        end
    end
    
    SyncService->>Observer: notify(syncCompleted, result)
    Observer->>Observer: Update UI completion
    SyncService->>CloudSyncApp: Return SyncResult
    CloudSyncApp->>User: Show sync completion
```

---

## User Authentication Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant CloudSyncApp
    participant SecurityManager
    participant NetworkManager
    participant AuthService as Cloud Auth Service
    participant ConfigurationManager

    User->>CloudSyncApp: Enter credentials
    CloudSyncApp->>CloudSyncApp: Validate input format
    
    alt Invalid input format
        CloudSyncApp->>User: Show validation errors
    else Valid input format
        CloudSyncApp->>SecurityManager: authenticateUser(credentials)
        SecurityManager->>SecurityManager: Hash password
        
        SecurityManager->>NetworkManager: POST /auth/login
        NetworkManager->>AuthService: Send login request
        
        alt Authentication successful
            AuthService->>NetworkManager: Return user data + token
            NetworkManager->>SecurityManager: Return auth response
            
            SecurityManager->>SecurityManager: Validate token
            SecurityManager->>ConfigurationManager: Store auth token
            ConfigurationManager->>SecurityManager: Confirm storage
            
            SecurityManager->>CloudSyncApp: Return authenticated user
            CloudSyncApp->>CloudSyncApp: Set current user
            CloudSyncApp->>User: Show main application
            
        else Authentication failed
            AuthService->>NetworkManager: Return error (401)
            NetworkManager->>SecurityManager: Return auth error
            SecurityManager->>CloudSyncApp: Return authentication error
            CloudSyncApp->>User: Show error message
            
        else Network error  
            NetworkManager->>SecurityManager: Return network error
            SecurityManager->>CloudSyncApp: Return network error
            CloudSyncApp->>User: Show connection error
            
        else Server error
            AuthService->>NetworkManager: Return server error (500)
            NetworkManager->>SecurityManager: Return server error
            SecurityManager->>CloudSyncApp: Return server error  
            CloudSyncApp->>User: Show server error message
        end
    end
    
    opt Token refresh needed
        SecurityManager->>NetworkManager: POST /auth/refresh
        NetworkManager->>AuthService: Send refresh request
        AuthService->>NetworkManager: Return new token
        NetworkManager->>SecurityManager: Return refresh response
        SecurityManager->>ConfigurationManager: Update stored token
    end
```

---

## Component Architecture Diagram

```mermaid
graph TB
    subgraph "Presentation Layer"
        ConsoleUI[Console UI Manager]
        ProgressBar[Progress Bar UI]
        ErrorDisplay[Error Display]
    end
    
    subgraph "Application Layer"
        CloudSyncApp[CloudSync Application]
        SyncCoordinator[Sync Coordinator]
        EventDispatcher[Event Dispatcher]
    end
    
    subgraph "Service Layer"
        SyncService[Sync Service]
        AuthService[Authentication Service]
        ConflictResolver[Conflict Resolution Service]
        NotificationService[Notification Service]
    end
    
    subgraph "Strategy Layer"
        SyncStrategyFactory[Sync Strategy Factory]
        FullSync[Full Sync Strategy]
        DeltaSync[Delta Sync Strategy]
        ScheduledSync[Scheduled Sync Strategy]
        SelectiveSync[Selective Sync Strategy]
    end
    
    subgraph "Repository Layer"
        FileRepo[File Repository]
        CloudRepo[Cloud Repository]
        UserRepo[User Repository]
        ConfigRepo[Configuration Repository]
    end
    
    subgraph "Infrastructure Layer"
        NetworkMgr[Network Manager]
        StorageMgr[Storage Manager]
        SecurityMgr[Security Manager]
        ConfigMgr[Configuration Manager]
        CacheMgr[Cache Manager]
        LoggingMgr[Logging Manager]
    end
    
    subgraph "Data Layer"
        Realm[(Realm Database)]
        FileSystem[(File System)]
        ConfigFiles[(Configuration Files)]
        LogFiles[(Log Files)]
    end
    
    subgraph "External Services"
        CloudAPI[Cloud Storage API]
        AuthAPI[Authentication API]
        NotificationAPI[Push Notification API]
        AnalyticsAPI[Analytics API]
    end

    %% Presentation to Application
    ConsoleUI --> CloudSyncApp
    ProgressBar --> SyncCoordinator
    ErrorDisplay --> EventDispatcher

    %% Application to Service
    CloudSyncApp --> SyncService
    CloudSyncApp --> AuthService
    SyncCoordinator --> ConflictResolver
    EventDispatcher --> NotificationService

    %% Service to Strategy
    SyncService --> SyncStrategyFactory
    SyncStrategyFactory --> FullSync
    SyncStrategyFactory --> DeltaSync
    SyncStrategyFactory --> ScheduledSync
    SyncStrategyFactory --> SelectiveSync

    %% Service to Repository
    SyncService --> FileRepo
    SyncService --> CloudRepo
    AuthService --> UserRepo
    CloudSyncApp --> ConfigRepo

    %% Repository to Infrastructure
    FileRepo --> StorageMgr
    CloudRepo --> NetworkMgr
    CloudRepo --> SecurityMgr
    UserRepo --> SecurityMgr
    ConfigRepo --> ConfigMgr
    FileRepo --> CacheMgr
    SyncService --> LoggingMgr

    %% Infrastructure to Data
    StorageMgr --> FileSystem
    NetworkMgr --> CloudAPI
    SecurityMgr --> AuthAPI
    ConfigMgr --> ConfigFiles
    LoggingMgr --> LogFiles
    FileRepo --> Realm

    %% Infrastructure to External
    NetworkMgr --> CloudAPI
    NetworkMgr --> AuthAPI
    NotificationService --> NotificationAPI
    LoggingMgr --> AnalyticsAPI

    %% Cross-cutting concerns
    SecurityMgr -.-> SyncService
    CacheMgr -.-> CloudRepo
    LoggingMgr -.-> SyncService
    EventDispatcher -.-> SyncService
```

---

## Service Layer Diagram

```mermaid
classDiagram
    class SyncService {
        -observers: [SyncObserver]
        -fileRepository: FileRepository
        -cloudRepository: CloudRepository
        -strategyFactory: SyncStrategyFactory
        -conflictResolver: ConflictResolver
        -syncQueue: SyncQueue
        -logger: Logger
        +addObserver(observer: SyncObserver): Void
        +removeObserver(observer: SyncObserver): Void
        +syncFile(file: SyncFile): Observable~SyncResult~
        +syncAll(): Observable~[SyncResult]~
        +batchSync(files: [SyncFile]): Observable~[SyncResult]~
        +pauseSync(): Void
        +resumeSync(): Void
        +cancelSync(fileId: String): Void
        +getSyncStatus(): SyncStatus
        +getSyncQueue(): [SyncFile]
        -selectStrategy(file: SyncFile): SyncStrategy
        -executeSync(file: SyncFile, strategy: SyncStrategy): Observable~SyncResult~
        -handleConflict(localFile: SyncFile, remoteFile: SyncFile): Observable~SyncResult~
        -notifyObservers(event: SyncEvent): Void
    }

    class ConflictResolver {
        -resolutionStrategies: [ConflictResolutionStrategy]
        -logger: Logger
        +resolveConflict(localFile: SyncFile, remoteFile: SyncFile): Observable~ConflictResolution~
        +addResolutionStrategy(strategy: ConflictResolutionStrategy): Void
        +removeResolutionStrategy(strategy: ConflictResolutionStrategy): Void
        -selectResolutionStrategy(conflict: Conflict): ConflictResolutionStrategy
        -applyResolution(resolution: ConflictResolution): Observable~SyncFile~
    }

    class AuthService {
        -securityManager: SecurityManager
        -networkManager: NetworkManager
        -tokenManager: TokenManager
        -logger: Logger
        +authenticateUser(credentials: Credentials): Observable~User~
        +refreshToken(): Observable~String~
        +logout(): Observable~Void~
        +validateSession(): Observable~Bool~
        +getCurrentUser(): User?
        -handleAuthError(error: AuthError): Observable~Never~
    }

    class NotificationService {
        -observers: [NotificationObserver]
        -userPreferences: UserPreferences
        -logger: Logger
        +sendNotification(notification: Notification): Observable~Void~
        +addObserver(observer: NotificationObserver): Void
        +removeObserver(observer: NotificationObserver): Void
        +updatePreferences(preferences: NotificationPreferences): Void
        -shouldSendNotification(type: NotificationType): Bool
        -formatNotification(event: SyncEvent): Notification
    }

    %% Service relationships
    SyncService --> ConflictResolver
    SyncService --> AuthService
    SyncService --> NotificationService
    ConflictResolver --> SyncService
    AuthService --> SecurityManager
    NotificationService --> UserPreferences
