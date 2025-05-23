// Subject.swift
// Defines the Subject interface that all concrete subjects must implement

import Foundation

/// Subject protocol defines the interface for objects that can be observed
protocol Subject {
    /// Register an observer to receive updates from this subject
    /// - Parameter observer: The observer to register
    func register(observer: Observer)
    
    /// Unregister an observer to stop receiving updates from this subject
    /// - Parameter observer: The observer to unregister
    func unregister(observer: Observer)
    
    /// Notify all registered observers of a change
    func notifyObservers()
}
