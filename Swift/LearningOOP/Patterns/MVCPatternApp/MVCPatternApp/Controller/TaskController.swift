//
//  TaskController.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//



import Foundation
import Combine

// TaskController - Controller component that mediates between Model and View
class TaskController: ObservableObject {
    // Reference to the model
    private let taskStore = TaskStore()
    
    // Published properties that the View can observe
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var selectedCategory: TaskCategory?
    @Published var selectedPriority: TaskPriority?
    @Published var selectedStatus: TaskStatus?
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .dueDate
    @Published var showCompletedTasks: Bool = true
    @Published var selectedTab: Int = 0
    
    // Sort options
    enum SortOption: String, CaseIterable, Identifiable {
        case title = "Title"
        case dueDate = "Due Date"
        case priority = "Priority"
        case category = "Category"
        case creationDate = "Creation Date"
        
        var id: String { self.rawValue }
    }
    
    // Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load sample data if needed
        taskStore.addSampleTasks()
        
        // Subscribe to changes in the task store
        taskStore.$tasks
            .sink { [weak self] tasks in
                self?.tasks = tasks
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        // Set up publishers for filter changes
        $selectedCategory
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
//            .combineLatest($selectedPriority, $selectedStatus, $searchText, $sortOption, $showCompletedTasks)
    }
    
    // MARK: - Task Management Methods
    
    func addTask(_ task: Task) {
        taskStore.addTask(task)
    }
    
    func updateTask(_ task: Task) {
        taskStore.updateTask(task)
    }
    
    func deleteTask(withId id: UUID) {
        taskStore.deleteTask(withId: id)
    }
    
    func getTask(withId id: UUID) -> Task? {
        return taskStore.getTask(withId: id)
    }
    
    func markTaskAsCompleted(id: UUID) {
        if var task = getTask(withId: id) {
            task.markAsCompleted()
            updateTask(task)
        }
    }
    
    func updateTaskStatus(id: UUID, status: TaskStatus) {
        if var task = getTask(withId: id) {
            task.updateStatus(status)
            updateTask(task)
        }
    }
    
    // MARK: - Filtering and Sorting Methods
    
    private func applyFilters() {
        var result = tasks
        
        // Filter by completion status
        if !showCompletedTasks {
            result = result.filter { $0.status != .completed }
        }
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Filter by priority
        if let priority = selectedPriority {
            result = result.filter { $0.priority == priority }
        }
        
        // Filter by status
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased()) ||
                $0.tags.contains { $0.lowercased().contains(searchText.lowercased()) }
            }
        }
        
        // Apply sorting
        result = sortTasks(result)
        
        // Update filtered tasks
        filteredTasks = result
    }
    
    private func sortTasks(_ tasks: [Task]) -> [Task] {
        switch sortOption {
        case .title:
            return tasks.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .dueDate:
            return tasks.sorted {
                guard let date1 = $0.dueDate else { return false }
                guard let date2 = $1.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            return tasks.sorted {
                let priorityOrder: [TaskPriority] = [.urgent, .high, .medium, .low]
                let index1 = priorityOrder.firstIndex(of: $0.priority) ?? 0
                let index2 = priorityOrder.firstIndex(of: $1.priority) ?? 0
                return index1 < index2
            }
        case .category:
            return tasks.sorted { $0.category.rawValue < $1.category.rawValue }
        case .creationDate:
            return tasks.sorted { $0.creationDate < $1.creationDate }
        }
    }
    
    // MARK: - Statistics Methods
    
    func completionRate() -> Double {
        return taskStore.completionRate()
    }
    
    func overdueTasks() -> [Task] {
        return taskStore.overdueTasks()
    }
    
    func tasksDueToday() -> [Task] {
        return taskStore.tasksDueToday()
    }
    
    func tasksDueThisWeek() -> [Task] {
        return taskStore.tasksDueThisWeek()
    }
    
    func taskCount(byCategory category: TaskCategory) -> Int {
        return taskStore.taskCount(byCategory: category)
    }
    
    func taskCount(byPriority priority: TaskPriority) -> Int {
        return taskStore.taskCount(byPriority: priority)
    }
    
    func taskCount(byStatus status: TaskStatus) -> Int {
        return taskStore.taskCount(byStatus: status)
    }
    
    // MARK: - Helper Methods
    
    func clearAllFilters() {
        selectedCategory = nil
        selectedPriority = nil
        selectedStatus = nil
        searchText = ""
        showCompletedTasks = true
    }
    
    // Add sample tasks via the TaskStore
    func addSampleTasks() {
        taskStore.addSampleTasks()
    }
    
    func resetToDefaultSort() {
        sortOption = .dueDate
    }
}

