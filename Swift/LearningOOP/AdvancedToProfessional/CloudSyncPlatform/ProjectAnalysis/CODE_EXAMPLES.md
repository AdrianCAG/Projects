# Code Examples for CloudSyncPlatform Improvements

This document provides concrete code examples for implementing the recommended improvements to the CloudSyncPlatform project.

## Table of Contents

1. [Testing Infrastructure](#testing-infrastructure)
2. [Dependency Injection Container](#dependency-injection-container)
3. [Circuit Breaker Pattern](#circuit-breaker-pattern)
4. [Caching Layer](#caching-layer)
5. [Enhanced Error Handling](#enhanced-error-handling)
6. [Monitoring and Metrics](#monitoring-and-metrics)
7. [Security Improvements](#security-improvements)
8. [Performance Optimizations](#performance-optimizations)

---

## Testing Infrastructure

### Unit Test Examples

```swift
// Tests/UnitTests/RepositoryTests/FileRepositoryTests.swift
import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import CloudSyncPlatform

class FileRepositoryTests: XCTestCase {
    var sut: FileRepositoryImpl!
    var mockStorageManager: MockStorageManager!
    var mockRealm: MockRealm!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockStorageManager = MockStorageManager()
        mockRealm = MockRealm()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        sut = FileRepositoryImpl(
            realm: mockRealm,
            storageManager: mockStorageManager,
            logger: MockLogger()
        )
    }
    
    override func tearDown() {
        disposeBag = nil
        scheduler = nil
        sut = nil
        mockRealm = nil
        mockStorageManager = nil
        super.tearDown()
    }
    
    func testCreateFile_ValidFile_SavesSuccessfully() {
        // Given
        let file = SyncFile(
            id: "test-id",
            name: "test.txt",
            path: "/documents/test.txt",
            size: 1024,
            checksum: "abc123",
            lastModified: Date(),
            isDeleted: false,
            isStarred: false,
            userId: "user-123"
        )
        
        mockRealm.shouldSucceed = true
        
        // When
        let result = sut.create(file).toBlocking().materialize()
        
        // Then
        switch result {
        case .completed(let elements):
            XCTAssertEqual(elements.count, 1)
            XCTAssertEqual(elements.first?.name, "test.txt")
            XCTAssertEqual(elements.first?.path, "/documents/test.txt")
            XCTAssertTrue(mockRealm.writeWasCalled)
        case .failed(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testCreateFile_RealmError_ThrowsError() {
        // Given
        let file = SyncFile(
            id: "test-id",
            name: "test.txt",
            path: "/documents/test.txt",
            size: 1024,
            checksum: "abc123",
            lastModified: Date(),
            isDeleted: false,
            isStarred: false,
            userId: "user-123"
        )
        
        mockRealm.shouldSucceed = false
        mockRealm.errorToThrow = TestError.realmWriteError
        
        // When
        let result = sut.create(file).toBlocking().materialize()
        
        // Then
        switch result {
        case .completed:
            XCTFail("Expected error, got success")
        case .failed(let error):
            XCTAssertTrue(error is TestError)
            XCTAssertEqual(error as? TestError, .realmWriteError)
        }
    }
    
    func testGetById_ExistingFile_ReturnsFile() {
        // Given
        let fileId = "existing-file-id"
        let expectedFile = createTestFile(id: fileId)
        mockRealm.mockFiles = [expectedFile.toRealmObject()]
        
        // When
        let result = sut.getById(fileId).toBlocking().materialize()
        
        // Then
        switch result {
        case .completed(let elements):
            XCTAssertEqual(elements.count, 1)
            XCTAssertEqual(elements.first??.id, fileId)
        case .failed(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    func testGetFilesInPath_WithFiles_ReturnsFilteredFiles() {
        // Given
        let targetPath = "/documents"
        let file1 = createTestFile(id: "1", path: "/documents/file1.txt")
        let file2 = createTestFile(id: "2", path: "/documents/file2.txt")
        let file3 = createTestFile(id: "3", path: "/images/file3.jpg")
        
        mockRealm.mockFiles = [
            file1.toRealmObject(),
            file2.toRealmObject(),
            file3.toRealmObject()
        ]
        
        // When
        let result = sut.getFilesInPath(targetPath).toBlocking().materialize()
        
        // Then
        switch result {
        case .completed(let elements):
            XCTAssertEqual(elements.count, 1)
            let files = elements.first ?? []
            XCTAssertEqual(files.count, 2)
            XCTAssertTrue(files.allSatisfy { $0.path.hasPrefix(targetPath) })
        case .failed(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestFile(id: String, path: String = "/test", name: String = "test.txt") -> SyncFile {
        return SyncFile(
            id: id,
            name: name,
            path: path,
            size: 1024,
            checksum: "abc123",
            lastModified: Date(),
            isDeleted: false,
            isStarred: false,
            userId: "user-123"
        )
    }
}

// Mock Classes
class MockStorageManager: StorageManagerProtocol {
    var shouldSucceed = true
    var errorToThrow: Error?
    var savedFiles: [String: Data] = [:]
    
    func saveFile(data: Data, path: String) -> Observable<Void> {
        if shouldSucceed {
            savedFiles[path] = data
            return Observable.just(())
        } else {
            return Observable.error(errorToThrow ?? TestError.storageError)
        }
    }
    
    func loadFile(path: String) -> Observable<Data> {
        if shouldSucceed, let data = savedFiles[path] {
            return Observable.just(data)
        } else {
            return Observable.error(errorToThrow ?? TestError.fileNotFound)
        }
    }
    
    func deleteFile(path: String) -> Observable<Void> {
        if shouldSucceed {
            savedFiles.removeValue(forKey: path)
            return Observable.just(())
        } else {
            return Observable.error(errorToThrow ?? TestError.deleteError)
        }
    }
}

class MockRealm: RealmProtocol {
    var mockFiles: [RealmSyncFile] = []
    var shouldSucceed = true
    var errorToThrow: Error?
    var writeWasCalled = false
    
    func write(_ block: () throws -> Void) throws {
        writeWasCalled = true
        if !shouldSucceed {
            throw errorToThrow ?? TestError.realmWriteError
        }
        try block()
    }
    
    func objects<T: Object>(_ type: T.Type) -> Results<T> {
        // Return mock results
        return MockResults(objects: mockFiles as! [T])
    }
    
    func add(_ object: Object) {
        if let syncFile = object as? RealmSyncFile {
            mockFiles.append(syncFile)
        }
    }
}

enum TestError: Error, Equatable {
    case realmWriteError
    case storageError
    case fileNotFound
    case deleteError
    case networkError
}
```

### Integration Test Examples

```swift
// Tests/IntegrationTests/SyncFlowTests.swift
import XCTest
import RxSwift
import RxTest
@testable import CloudSyncPlatform

class SyncFlowIntegrationTests: XCTestCase {
    var app: CloudSyncApp!
    var testContainer: TestDIContainer!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        // Setup test container with real implementations
        testContainer = TestDIContainer()
        setupTestDependencies()
        
        app = CloudSyncApp(container: testContainer)
    }
    
    func testFullSyncFlow_NewFile_UploadsSuccessfully() {
        // Given
        let testFile = createTestFile()
        let mockCloudRepo = testContainer.resolve(CloudRepository.self) as! MockCloudRepository
        mockCloudRepo.shouldSucceedUpload = true
        
        // When
        let syncResult = app.syncService.syncFile(testFile)
            .toBlocking()
            .materialize()
        
        // Then
        switch syncResult {
        case .completed(let elements):
            let result = elements.first!
            XCTAssertEqual(result.status, .success)
            XCTAssertEqual(result.file.id, testFile.id)
            XCTAssertTrue(mockCloudRepo.uploadWasCalled)
        case .failed(let error):
            XCTFail("Expected successful sync, got error: \(error)")
        }
    }
    
    func testConflictResolution_LocalNewer_UploadsLocal() {
        // Given
        let localFile = createTestFile(lastModified: Date())
        let remoteFile = createTestFile(lastModified: Date().addingTimeInterval(-3600)) // 1 hour ago
        
        let mockCloudRepo = testContainer.resolve(CloudRepository.self) as! MockCloudRepository
        mockCloudRepo.remoteFile = remoteFile
        mockCloudRepo.shouldSucceedUpload = true
        
        // When
        let syncResult = app.syncService.syncFile(localFile)
            .toBlocking()
            .materialize()
        
        // Then
        switch syncResult {
        case .completed(let elements):
            let result = elements.first!
            XCTAssertEqual(result.status, .success)
            XCTAssertTrue(mockCloudRepo.uploadWasCalled)
            XCTAssertFalse(mockCloudRepo.downloadWasCalled)
        case .failed(let error):
            XCTFail("Expected successful sync, got error: \(error)")
        }
    }
    
    private func setupTestDependencies() {
        // Register test implementations
        testContainer.register(FileRepository.self, instance: MockFileRepository())
        testContainer.register(CloudRepository.self, instance: MockCloudRepository())
        testContainer.register(SyncStrategyFactory.self, instance: MockSyncStrategyFactory())
        testContainer.register(Logger.self, instance: MockLogger())
    }
    
    private func createTestFile(lastModified: Date = Date()) -> SyncFile {
        return SyncFile(
            id: UUID().uuidString,
            name: "test.txt",
            path: "/test/test.txt",
            size: 1024,
            checksum: "abc123",
            lastModified: lastModified,
            isDeleted: false,
            isStarred: false,
            userId: "test-user"
        )
    }
}
```

---

## Dependency Injection Container

### DI Container Implementation

```swift
// Sources/DependencyInjection/DIContainer.swift
import Foundation

protocol DIContainer {
    func register<T>(_ type: T.Type, instance: T)
    func register<T>(_ type: T.Type, factory: @escaping (DIContainer) -> T)
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T>(_ type: T.Type) -> T?
}

class CloudSyncDIContainer: DIContainer {
    private var singletonInstances: [String: Any] = [:]
    private var factories: [String: (DIContainer) -> Any] = [:]
    private var simpleFactories: [String: () -> Any] = [:]
    private let queue = DispatchQueue(label: "di.container", attributes: .concurrent)
    
    func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        queue.async(flags: .barrier) {
            self.singletonInstances[key] = instance
        }
    }
    
    func register<T>(_ type: T.Type, factory: @escaping (DIContainer) -> T) {
        let key = String(describing: type)
        queue.async(flags: .barrier) {
            self.factories[key] = factory
        }
    }
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        queue.async(flags: .barrier) {
            self.simpleFactories[key] = factory
        }
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        guard let instance: T = resolve(type) else {
            fatalError("Unable to resolve type: \(type). Make sure it's registered.")
        }
        return instance
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        
        return queue.sync {
            // Check for singleton instance
            if let instance = singletonInstances[key] as? T {
                return instance
            }
            
            // Check for factory with container
            if let factory = factories[key] {
                let instance = factory(self) as! T
                return instance
            }
            
            // Check for simple factory
            if let factory = simpleFactories[key] {
                let instance = factory() as! T
                return instance
            }
            
            return nil
        }
    }
}

// Dependency Setup
class DependencySetup {
    static func configureDependencies(_ container: DIContainer) {
        // Register singletons
        container.register(ConfigurationManagerProtocol.self, instance: ConfigurationManager())
        container.register(StorageManagerProtocol.self, instance: StorageManager())
        container.register(NetworkManagerProtocol.self, instance: NetworkManager())
        container.register(SecurityManagerProtocol.self, instance: SecurityManager())
        
        // Register logger
        container.register(Logger.self) {
            Logger(label: "com.cloudsync.main")
        }
        
        // Register repositories with dependencies
        container.register(FileRepository.self) { container in
            FileRepositoryImpl(
                realm: try! Realm(),
                storageManager: container.resolve(StorageManagerProtocol.self),
                logger: container.resolve(Logger.self)
            )
        }
        
        container.register(CloudRepository.self) { container in
            CloudRepositoryImpl(
                networkManager: container.resolve(NetworkManagerProtocol.self),
                securityManager: container.resolve(SecurityManagerProtocol.self),
                logger: container.resolve(Logger.self)
            )
        }
        
        // Register services
        container.register(SyncStrategyFactory.self) { container in
            DefaultSyncStrategyFactory(
                fileRepository: container.resolve(FileRepository.self),
                cloudRepository: container.resolve(CloudRepository.self),
                deltaGenerator: DeltaGenerator(),
                logger: container.resolve(Logger.self)
            )
        }
        
        container.register(SyncServiceProtocol.self) { container in
            SyncService(
                fileRepository: container.resolve(FileRepository.self),
                cloudRepository: container.resolve(CloudRepository.self),
                strategyFactory: container.resolve(SyncStrategyFactory.self),
                logger: container.resolve(Logger.self)
            )
        }
        
        // Register UI components
        container.register(ConsoleUI.self) { container in
            ConsoleUI(logger: container.resolve(Logger.self))
        }
    }
}

// Updated CloudSyncApp to use DI
class CloudSyncApp {
    private let container: DIContainer
    private let disposeBag = DisposeBag()
    
    // Resolved dependencies
    private lazy var syncService: SyncServiceProtocol = container.resolve(SyncServiceProtocol.self)
    private lazy var ui: ConsoleUI = container.resolve(ConsoleUI.self)
    private lazy var logger: Logger = container.resolve(Logger.self)
    
    init(container: DIContainer = CloudSyncDIContainer()) {
        self.container = container
        DependencySetup.configureDependencies(container)
        setupObservers()
    }
    
    func run() {
        logger.info("Starting CloudSync Platform")
        ui.displayWelcome()
        
        // Start main application loop
        startMainLoop()
    }
    
    private func setupObservers() {
        let uiObserver = ConsoleUIObserver(ui: ui)
        let loggingObserver = LoggingObserver(logger: logger)
        
        syncService.addObserver(uiObserver)
        syncService.addObserver(loggingObserver)
    }
    
    private func startMainLoop() {
        // Implementation...
    }
}
```

### Protocol-Based Dependencies

```swift
// Sources/Protocols/ManagerProtocols.swift
protocol ConfigurationManagerProtocol {
    func getProperty<T>(key: String, defaultValue: T) -> T
    func setProperty<T>(key: String, value: T)
    func loadConfiguration()
    func saveConfiguration() -> Observable<Void>
}

protocol StorageManagerProtocol {
    func saveFile(data: Data, path: String) -> Observable<Void>
    func loadFile(path: String) -> Observable<Data>
    func deleteFile(path: String) -> Observable<Void>
    func fileExists(path: String) -> Bool
    func createDirectory(path: String) -> Observable<Void>
}

protocol NetworkManagerProtocol {
    func request(_ endpoint: APIEndpoint) -> Observable<Data>
    func uploadFile(data: Data, endpoint: String) -> Observable<Void>
    func downloadFile(url: String) -> Observable<Data>
    func setAuthToken(_ token: String)
}

protocol SecurityManagerProtocol {
    func encrypt(data: Data) -> Data
    func decrypt(data: Data) -> Data
    func authenticateUser(credentials: Credentials) -> Observable<User>
    func generateToken(user: User) -> String
    func validateToken(token: String) -> Observable<User>
}

// Update existing managers to implement protocols
extension ConfigurationManager: ConfigurationManagerProtocol {}
extension StorageManager: StorageManagerProtocol {}
extension NetworkManager: NetworkManagerProtocol {}
extension SecurityManager: SecurityManagerProtocol {}
```

---

## Circuit Breaker Pattern

### Circuit Breaker Implementation

```swift
// Sources/Resilience/CircuitBreaker.swift
import Foundation
import RxSwift

enum CircuitBreakerState {
    case closed
    case open
    case halfOpen
}

enum CircuitBreakerError: Error {
    case circuitOpen
    case circuitHalfOpenCallFailed
    case configurationError
}

protocol CircuitBreakerProtocol {
    func execute<T>(_ operation: @escaping () -> Observable<T>) -> Observable<T>
    func getState() -> CircuitBreakerState
    func getFailureCount() -> Int
    func reset()
}

class CircuitBreaker: CircuitBreakerProtocol {
    private let failureThreshold: Int
    private let recoveryTimeout: TimeInterval
    private let halfOpenMaxCalls: Int
    
    private var state: CircuitBreakerState = .closed
    private var failureCount = 0
    private var lastFailureTime: Date?
    private var halfOpenCallCount = 0
    private var halfOpenSuccessCount = 0
    
    private let queue = DispatchQueue(label: "circuit-breaker", attributes: .concurrent)
    private let logger: Logger
    
    init(failureThreshold: Int = 5,
         recoveryTimeout: TimeInterval = 30,
         halfOpenMaxCalls: Int = 3,
         logger: Logger) {
        self.failureThreshold = failureThreshold
        self.recoveryTimeout = recoveryTimeout
        self.halfOpenMaxCalls = halfOpenMaxCalls
        self.logger = logger
    }
    
    func execute<T>(_ operation: @escaping () -> Observable<T>) -> Observable<T> {
        return Observable.create { observer in
            let currentState = self.getCurrentState()
            
            switch currentState {
            case .open:
                self.logger.warning("Circuit breaker is OPEN - failing fast")
                observer.onError(CircuitBreakerError.circuitOpen)
                return Disposables.create()
                
            case .halfOpen:
                return self.executeInHalfOpenState(operation, observer: observer)
                
            case .closed:
                return self.executeInClosedState(operation, observer: observer)
            }
        }
    }
    
    private func getCurrentState() -> CircuitBreakerState {
        return queue.sync {
            if state == .open && shouldAttemptReset() {
                state = .halfOpen
                halfOpenCallCount = 0
                halfOpenSuccessCount = 0
                logger.info("Circuit breaker transitioning to HALF_OPEN")
            }
            return state
        }
    }
    
    private func shouldAttemptReset() -> Bool {
        guard let lastFailure = lastFailureTime else { return false }
        return Date().timeIntervalSince(lastFailure) >= recoveryTimeout
    }
    
    private func executeInClosedState<T>(_ operation: @escaping () -> Observable<T>,
                                        observer: AnyObserver<T>) -> Disposable {
        return operation()
            .do(onNext: { _ in self.onSuccess() },
                onError: { error in self.onFailure(error) })
            .subscribe(observer)
    }
    
    private func executeInHalfOpenState<T>(_ operation: @escaping () -> Observable<T>,
                                          observer: AnyObserver<T>) -> Disposable {
        let shouldExecute = queue.sync { () -> Bool in
            if halfOpenCallCount >= halfOpenMaxCalls {
                return false
            }
            halfOpenCallCount += 1
            return true
        }
        
        if !shouldExecute {
            observer.onError(CircuitBreakerError.circuitOpen)
            return Disposables.create()
        }
        
        return operation()
            .do(onNext: { _ in self.onHalfOpenSuccess() },
                onError: { error in self.onHalfOpenFailure(error) })
            .subscribe(observer)
    }
    
    private func onSuccess() {
        queue.async(flags: .barrier) {
            self.failureCount = 0
            if self.state == .halfOpen {
                self.logger.info("Circuit breaker transitioning to CLOSED")
            }
            self.state = .closed
        }
    }
    
    private func onFailure(_ error: Error) {
        queue.async(flags: .barrier) {
            self.failureCount += 1
            self.lastFailureTime = Date()
            
            if self.failureCount >= self.failureThreshold {
                self.state = .open
                self.logger.warning("Circuit breaker transitioning to OPEN due to failures: \(self.failureCount)")
            }
        }
    }
    
    private func onHalfOpenSuccess() {
        queue.async(flags: .barrier) {
            self.halfOpenSuccessCount += 1
            
            if self.halfOpenSuccessCount >= self.halfOpenMaxCalls {
                self.state = .closed
                self.failureCount = 0
                self.logger.info("Circuit breaker transitioning to CLOSED after half-open success")
            }
        }
    }
    
    private func onHalfOpenFailure(_ error: Error) {
        queue.async(flags: .barrier) {
            self.state = .open
            self.lastFailureTime = Date()
            self.failureCount += 1
            self.logger.warning("Circuit breaker transitioning to OPEN from half-open failure")
        }
    }
    
    func getState() -> CircuitBreakerState {
        return queue.sync { state }
    }
    
    func getFailureCount() -> Int {
        return queue.sync { failureCount }
    }
    
    func reset() {
        queue.async(flags: .barrier) {
            self.state = .closed
            self.failureCount = 0
            self.lastFailureTime = nil
            self.halfOpenCallCount = 0
            self.halfOpenSuccessCount = 0
            self.logger.info("Circuit breaker manually reset")
        }
    }
}

// Enhanced Network Manager with Circuit Breaker
class ResilientNetworkManager: NetworkManagerProtocol {
    private let baseNetworkManager: NetworkManagerProtocol
    private let circuitBreaker: CircuitBreakerProtocol
    private let logger: Logger
    
    init(baseNetworkManager: NetworkManagerProtocol,
         circuitBreaker: CircuitBreakerProtocol,
         logger: Logger) {
        self.baseNetworkManager = baseNetworkManager
        self.circuitBreaker = circuitBreaker
        self.logger = logger
    }
    
    func request(_ endpoint: APIEndpoint) -> Observable<Data> {
        return circuitBreaker.execute {
            self.baseNetworkManager.request(endpoint)
                .retryWithExponentialBackoff(maxRetries: 3)
        }
    }
    
    func uploadFile(data: Data, endpoint: String) -> Observable<Void> {
        return circuitBreaker.execute {
            self.baseNetworkManager.uploadFile(data: data, endpoint: endpoint)
                .retryWithExponentialBackoff(maxRetries: 2)
        }
    }
    
    func downloadFile(url: String) -> Observable<Data> {
        return circuitBreaker.execute {
            self.baseNetworkManager.downloadFile(url: url)
                .retryWithExponentialBackoff(maxRetries: 3)
        }
    }
    
    func setAuthToken(_ token: String) {
        baseNetworkManager.setAuthToken(token)
    }
}

// Retry with Exponential Backoff Extension
extension Observable {
    func retryWithExponentialBackoff(maxRetries: Int = 3,
                                   baseDelay: TimeInterval = 1.0,
                                   maxDelay: TimeInterval = 60.0,
                                   retryableErrorPredicate: @escaping (Error) -> Bool = { _ in true }) -> Observable<Element> {
        return self.retryWhen { errors in
            errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                guard attempt < maxRetries && retryableErrorPredicate(error) else {
                    return Observable.error(error)
                }
                
                let delay = min(baseDelay * pow(2.0, Double(attempt)), maxDelay)
                let jitter = Double.random(in: 0...0.1) * delay
                let finalDelay = delay + jitter
                
                return Observable<Void>.just(())
                    .delay(.milliseconds(Int(finalDelay * 1000)), scheduler: MainScheduler.instance)
            }
        }
    }
}
```

---

## Caching Layer

### Multi-Level Cache Implementation

```swift
// Sources/Cache/CacheManager.swift
import Foundation
import RxSwift

protocol CacheManager {
    func get<T: Codable>(key: String, type: T.Type) -> Observable<T?>
    func set<T: Codable>(key: String, value: T, expiration: TimeInterval?) -> Observable<Void>
    func remove(key: String) -> Observable<Void>
    func clear() -> Observable<Void>
    func contains(key: String) -> Bool
}

// Memory Cache Implementation
class MemoryCacheManager: CacheManager {
    private struct CacheEntry {
        let value: Any
        let expiration: Date?
        let createdAt: Date
        
        var isExpired: Bool {
            guard let expiration = expiration else { return false }
            return Date() > expiration
        }
    }
    
    private var cache: [String: CacheEntry] = [:]
    private let queue = DispatchQueue(label: "memory-cache", attributes: .concurrent)
    private let maxSize: Int
    private let cleanupInterval: TimeInterval
    private var cleanupTimer: Timer?
    
    init(maxSize: Int = 100, cleanupInterval: TimeInterval = 300) {
        self.maxSize = maxSize
        self.cleanupInterval = cleanupInterval
        startCleanupTimer()
    }
    
    deinit {
        cleanupTimer?.invalidate()
    }
    
    func get<T: Codable>(key: String, type: T.Type) -> Observable<T?> {
        return Observable.create { observer in
            self.queue.async {
                if let entry = self.cache[key], !entry.isExpired {
                    observer.onNext(entry.value as? T)
                } else {
                    self.cache.removeValue(forKey: key)
                    observer.onNext(nil)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func set<T: Codable>(key: String, value: T, expiration: TimeInterval?) -> Observable<Void> {
        return Observable.create { observer in
            self.queue.async(flags: .barrier) {
                let expirationDate = expiration.map { Date().addingTimeInterval($0) }
                let entry = CacheEntry(value: value, expiration: expirationDate, createdAt: Date())
                
                self.cache[key] = entry
                self.evictIfNeeded()
                
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func remove(key: String) -> Observable<Void> {
        return Observable.create { observer in
            self.queue.async(flags: .barrier) {
                self.cache.removeValue(forKey: key)
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func clear() -> Observable<Void> {
        return Observable.create { observer in
            self.queue.async(flags: .barrier) {
                self.cache.removeAll()
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
