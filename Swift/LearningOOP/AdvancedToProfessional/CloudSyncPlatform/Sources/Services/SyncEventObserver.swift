import Foundation

/// Sync Event Observer - Implements the Observer pattern
class SyncEventObserver: SyncObserver {
    // MARK: - Properties
    
    /// Event handler closure
    private let eventHandler: (SyncEvent) -> Void
    
    // MARK: - Initialization
    
    /// Initialize with an event handler
    /// - Parameter eventHandler: Closure to handle sync events
    init(eventHandler: @escaping (SyncEvent) -> Void) {
        self.eventHandler = eventHandler
    }
    
    // MARK: - SyncObserver Protocol
    
    /// Handle sync events
    /// - Parameter event: Sync event
    func onSyncEvent(_ event: SyncEvent) {
        eventHandler(event)
    }
}
