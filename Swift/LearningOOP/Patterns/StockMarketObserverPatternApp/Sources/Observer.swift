// Observer.swift
// Defines the Observer interface that all concrete observers must implement

import Foundation

/// Observer protocol defines the interface for objects that should be notified of changes
protocol Observer: AnyObject {
    /// The method called when the observed subject changes
    /// - Parameter data: Any relevant data the subject wants to pass to the observer
    func update(data: Any?)
    
    /// A unique identifier for the observer
    var id: UUID { get }
}
