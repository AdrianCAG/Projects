//
//  TaskStore.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import Foundation
import Combine

// TaskStore - Model component responsible for data storage and retrieval
class TaskStore: ObservableObject {
    // Published property that will notify observers when tasks change
    @Published private(set) var tasks: [Task] = []
    
    // File URL for data persistence
    private let saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("tasks.json")
    
    init() {
        loadTasks()
    }
    
    // MARK: - CRUD Operations
    
    // Create a new task
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    // Read/Get a specific task by ID
    func getTask(withId id: UUID) -> Task? {
        return tasks.first { $0.id == id }
    }
    
    // Update an existing task
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    // Delete a task
    func deleteTask(withId id: UUID) {
        tasks.removeAll { $0.id == id }
        saveTasks()
    }
    
    // MARK: - Filtering Methods
    
    // Get tasks by category
    func tasks(inCategory category: TaskCategory) -> [Task] {
        return tasks.filter { $0.category == category }
    }
    
    // Get tasks by status
    func tasks(withStatus status: TaskStatus) -> [Task] {
        return tasks.filter { $0.status == status }
    }
    
    // Get tasks by priority
    func tasks(withPriority priority: TaskPriority) -> [Task] {
        return tasks.filter { $0.priority == priority }
    }
    
    // Get overdue tasks
    func overdueTasks() -> [Task] {
        return tasks.filter { $0.isOverdue }
    }
    
    // Get tasks due today
    func tasksDueToday() -> [Task] {
        let calendar = Calendar.current
        return tasks.filter { task in
            if let dueDate = task.dueDate {
                return calendar.isDateInToday(dueDate) && task.status != .completed && task.status != .cancelled
            }
            return false
        }
    }
    
    // Get tasks due this week
    func tasksDueThisWeek() -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        
        return tasks.filter { task in
            if let dueDate = task.dueDate {
                let taskDate = calendar.startOfDay(for: dueDate)
                return taskDate >= today && taskDate <= endOfWeek && task.status != .completed && task.status != .cancelled
            }
            return false
        }
    }
    
    // MARK: - Statistics Methods
    
    // Get completion rate
    func completionRate() -> Double {
        let completedCount = tasks.filter { $0.status == .completed }.count
        return tasks.isEmpty ? 0 : Double(completedCount) / Double(tasks.count)
    }
    
    // Get task count by category
    func taskCount(byCategory category: TaskCategory) -> Int {
        return tasks(inCategory: category).count
    }
    
    // Get task count by priority
    func taskCount(byPriority priority: TaskPriority) -> Int {
        return tasks(withPriority: priority).count
    }
    
    // Get task count by status
    func taskCount(byStatus status: TaskStatus) -> Int {
        return tasks(withStatus: status).count
    }
    
    // MARK: - Persistence Methods
    
    // Save tasks to disk
    private func saveTasks() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(tasks)
            try data.write(to: saveURL)
        } catch {
            print("Error saving tasks: \(error)")
        }
    }
    
    // Load tasks from disk
    private func loadTasks() {
        do {
            guard FileManager.default.fileExists(atPath: saveURL.path) else { return }
            let data = try Data(contentsOf: saveURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            tasks = try decoder.decode([Task].self, from: data)
        } catch {
            print("Error loading tasks: \(error)")
        }
    }
    
    // MARK: - Sample Data
    
    // Add sample tasks for testing
    func addSampleTasks() {
        // Only add sample data if the store is empty
        guard tasks.isEmpty else { return }
        
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        
        let sampleTasks = [
            Task(
                title: "Complete project proposal",
                description: "Finish the draft and send it to the team for review",
                category: .work,
                priority: .high,
                dueDate: tomorrow,
                status: .inProgress,
                tags: ["project", "deadline"]
            ),
            Task(
                title: "Go for a run",
                description: "30 minutes jogging in the park",
                category: .health,
                priority: .medium,
                dueDate: today,
                tags: ["exercise", "routine"]
            ),
            Task(
                title: "Pay electricity bill",
                description: "Due by the end of the month",
                category: .finance,
                priority: .urgent,
                dueDate: nextWeek,
                tags: ["bills", "monthly"]
            ),
            Task(
                title: "Buy groceries",
                description: "Milk, eggs, bread, vegetables",
                category: .home,
                priority: .low,
                dueDate: tomorrow,
                tags: ["shopping", "food"]
            ),
            Task(
                title: "Study Swift programming",
                description: "Focus on SwiftUI and Combine framework",
                category: .education,
                priority: .high,
                dueDate: calendar.date(byAdding: .day, value: 3, to: today),
                status: .inProgress,
                tags: ["learning", "coding"]
            )
        ]
        
        for task in sampleTasks {
            addTask(task)
        }
    }
}
