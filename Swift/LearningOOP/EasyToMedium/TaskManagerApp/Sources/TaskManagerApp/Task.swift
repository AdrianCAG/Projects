// Task.swift - Defines the Task class and related protocols/subclasses

import Foundation

// Task Priority enum - demonstrates enumeration in Swift
enum Priority: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

// Task Status enum - demonstrates enumeration in Swift
enum TaskStatus: String, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
}

// Task Protocol - demonstrates protocol/interface concept
protocol TaskProtocol {
    var title: String { get set }
    var description: String { get set }
    var priority: Priority { get set }
    var status: TaskStatus { get set }
    var creationDate: Date { get }
    
    func markAsCompleted()
    func updateStatus(to status: TaskStatus)
    func display()
}

// Base Task class - demonstrates encapsulation
class Task: TaskProtocol {
    var title: String
    var description: String
    var priority: Priority
    var status: TaskStatus
    let creationDate: Date
    
    // Initializer (constructor)
    init(title: String, description: String, priority: Priority = .medium) {
        self.title = title
        self.description = description
        self.priority = priority
        self.status = .notStarted
        self.creationDate = Date()
    }
    
    // Method implementation
    func markAsCompleted() {
        status = .completed
    }
    
    // Method implementation
    func updateStatus(to status: TaskStatus) {
        self.status = status
    }
    
    // Method implementation
    func display() {
        print("Task: \(title)")
        print("Description: \(description)")
        print("Priority: \(priority.description)")
        print("Status: \(status.rawValue)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        print("Created on: \(dateFormatter.string(from: creationDate))")
    }
}

// WorkTask - demonstrates inheritance
class WorkTask: Task {
    var project: String
    var deadline: Date?
    
    init(title: String, description: String, priority: Priority = .medium, project: String, deadline: Date? = nil) {
        self.project = project
        self.deadline = deadline
        super.init(title: title, description: description, priority: priority)
    }
    
    // Method overriding - demonstrates polymorphism
    override func display() {
        super.display()
        print("Project: \(project)")
        
        if let deadline = deadline {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            print("Deadline: \(dateFormatter.string(from: deadline))")
        }
    }
}

// PersonalTask - demonstrates inheritance
class PersonalTask: Task {
    var location: String?
    
    init(title: String, description: String, priority: Priority = .medium, location: String? = nil) {
        self.location = location
        super.init(title: title, description: description, priority: priority)
    }
    
    // Method overriding - demonstrates polymorphism
    override func display() {
        super.display()
        if let location = location {
            print("Location: \(location)")
        }
    }
}
