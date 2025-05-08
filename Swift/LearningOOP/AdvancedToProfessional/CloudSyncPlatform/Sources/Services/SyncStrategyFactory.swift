import Foundation
import Logging
import RxSwift

/// Sync Strategy Type
enum SyncStrategyType: String {
    case full
    case delta
    case scheduled
    case selective
}

/// Sync Strategy Factory Protocol
protocol SyncStrategyFactoryProtocol {
    /// Create a sync strategy
    /// - Parameters:
    ///   - type: Strategy type
    ///   - fileRepository: File repository
    ///   - cloudRepository: Cloud repository
    /// - Returns: Sync strategy
    func createStrategy(type: SyncStrategyType, fileRepository: any FileRepository, cloudRepository: CloudRepository) -> SyncStrategy
}

/// Sync Strategy Factory - Factory Pattern Implementation
class SyncStrategyFactory: SyncStrategyFactoryProtocol {
    // MARK: - Properties
    
    private let logger = Logger(label: "com.cloudsync.strategy.factory")
    private let deltaGenerator = DeltaGenerator()
    private let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    
    // MARK: - Initialization
    
    init() {
        logger.info("SyncStrategyFactory initialized")
    }
    
    // MARK: - Factory Methods
    
    /// Create a sync strategy
    /// - Parameters:
    ///   - type: Strategy type
    ///   - fileRepository: File repository
    ///   - cloudRepository: Cloud repository
    /// - Returns: Sync strategy
    func createStrategy(type: SyncStrategyType, fileRepository: any FileRepository, cloudRepository: CloudRepository) -> SyncStrategy {
        switch type {
        case .full:
            logger.info("Creating FullSyncStrategy")
            return FullSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository)
            
        case .delta:
            logger.info("Creating DeltaSyncStrategy")
            return DeltaSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository, deltaGenerator: deltaGenerator)
            
        case .scheduled:
            logger.info("Creating ScheduledSyncStrategy")
            return ScheduledSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository, scheduler: scheduler)
            
        case .selective:
            logger.info("Creating SelectiveSyncStrategy")
            // Default filter that includes all files
            let filter: (SyncFile) -> Bool = { _ in true }
            return SelectiveSyncStrategy(fileRepository: fileRepository, cloudRepository: cloudRepository, filter: filter)
        }
    }
}
