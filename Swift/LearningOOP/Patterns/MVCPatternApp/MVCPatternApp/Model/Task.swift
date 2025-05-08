//
//  Task.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import Foundation

// Task Priority enum
enum TaskPriority: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var id: String { self.rawValue }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

// Task Category enum
enum TaskCategory: String, CaseIterable, Identifiable, Codable {
    case personal = "Personal"
    case work = "Work"
    case health = "Health"
    case finance = "Finance"
    case education = "Education"
    case home = "Home"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .work: return "briefcase.fill"
        case .health: return "heart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .education: return "book.fill"
        case .home: return "house.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// Task Status enum
enum TaskStatus: String, CaseIterable, Identifiable, Codable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
    
    var id: String { self.rawValue }
}

// Task Model
struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var category: TaskCategory
    var priority: TaskPriority
    var dueDate: Date?
    var status: TaskStatus
    var creationDate: Date
    var completionDate: Date?
    var tags: [String]
    
    // Computed property to check if task is overdue
    var isOverdue: Bool {
        if let dueDate = dueDate, status != .completed, status != .cancelled {
            return dueDate < Date()
        }
        return false
    }
    
    // Computed property to get days remaining until due date
    var daysRemaining: Int? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day
    }
    
    // Initialize with default values
    init(
        title: String,
        description: String = "",
        category: TaskCategory = .other,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        status: TaskStatus = .pending,
        tags: [String] = []
    ) {
        self.title = title
        self.description = description
        self.category = category
        self.priority = priority
        self.dueDate = dueDate
        self.status = status
        self.creationDate = Date()
        self.completionDate = nil
        self.tags = tags
    }
    
    // Method to mark task as completed
    mutating func markAsCompleted() {
        self.status = .completed
        self.completionDate = Date()
    }
    
    // Method to update task status
    mutating func updateStatus(_ newStatus: TaskStatus) {
        self.status = newStatus
        if newStatus == .completed {
            self.completionDate = Date()
        } else if newStatus != .completed {
            self.completionDate = nil
        }
    }
}

