// TaskManager.swift - Manages the collection of tasks and user interaction

import Foundation

// TaskManager class - demonstrates composition and collection management
class TaskManager {
    // Array to store tasks - demonstrates collection usage
    private var tasks: [Task] = []
    
    // Method to add a task
    func addTask(_ task: Task) {
        tasks.append(task)
        print("Task added successfully!")
    }
    
    // Method to remove a task
    func removeTask(at index: Int) {
        guard index >= 0 && index < tasks.count else {
            print("Invalid task index!")
            return
        }
        
        tasks.remove(at: index)
        print("Task removed successfully!")
    }
    
    // Method to display all tasks
    func displayAllTasks() {
        if tasks.isEmpty {
            print("No tasks available.")
            return
        }
        
        print("\n===== All Tasks =====")
        for (index, task) in tasks.enumerated() {
            print("\n--- Task #\(index + 1) ---")
            task.display()
        }
    }
    
    // Method to display tasks by status
    func displayTasksByStatus(_ status: TaskStatus) {
        let filteredTasks = tasks.filter { $0.status == status }
        
        if filteredTasks.isEmpty {
            print("No tasks with status: \(status.rawValue)")
            return
        }
        
        print("\n===== Tasks with Status: \(status.rawValue) =====")
        for (index, task) in filteredTasks.enumerated() {
            print("\n--- Task #\(index + 1) ---")
            task.display()
        }
    }
    
    // Method to update task status
    func updateTaskStatus(at index: Int, to status: TaskStatus) {
        guard index >= 0 && index < tasks.count else {
            print("Invalid task index!")
            return
        }
        
        tasks[index].updateStatus(to: status)
        print("Task status updated successfully!")
    }
    
    // Main application loop
    func run() {
        print("Welcome to Task Manager!")
        
        var running = true
        while running {
            displayMenu()
            
            if let choice = readLine(), let option = Int(choice) {
                switch option {
                case 1:
                    createTask()
                case 2:
                    displayAllTasks()
                case 3:
                    updateTask()
                case 4:
                    deleteTask()
                case 5:
                    filterTasks()
                case 6:
                    running = false
                    print("Thank you for using Task Manager. Goodbye!")
                default:
                    print("Invalid option. Please try again.")
                }
            } else {
                print("Invalid input. Please enter a number.")
            }
        }
    }
    
    // Helper method to display menu
    private func displayMenu() {
        print("\n===== Task Manager Menu =====")
        print("1. Create a new task")
        print("2. Display all tasks")
        print("3. Update a task")
        print("4. Delete a task")
        print("5. Filter tasks by status")
        print("6. Exit")
        print("Enter your choice (1-6): ", terminator: "")
    }
    
    // Helper method to create a task
    private func createTask() {
        print("\n===== Create a New Task =====")
        print("Select task type:")
        print("1. Regular Task")
        print("2. Work Task")
        print("3. Personal Task")
        print("Enter your choice (1-3): ", terminator: "")
        
        guard let typeChoice = readLine(), let taskType = Int(typeChoice), (1...3).contains(taskType) else {
            print("Invalid task type. Returning to main menu.")
            return
        }
        
        print("Enter task title: ", terminator: "")
        guard let title = readLine(), !title.isEmpty else {
            print("Title cannot be empty. Returning to main menu.")
            return
        }
        
        print("Enter task description: ", terminator: "")
        let description = readLine() ?? ""
        
        print("Select priority:")
        for (index, priority) in Priority.allCases.enumerated() {
            print("\(index + 1). \(priority.description)")
        }
        print("Enter your choice (1-3): ", terminator: "")
        
        let priorityChoice = Int(readLine() ?? "2") ?? 2
        let priority = Priority(rawValue: priorityChoice) ?? .medium
        
        var task: Task
        
        switch taskType {
        case 1:
            task = Task(title: title, description: description, priority: priority)
        case 2:
            print("Enter project name: ", terminator: "")
            let project = readLine() ?? "Default Project"
            
            print("Do you want to set a deadline? (y/n): ", terminator: "")
            let hasDeadline = readLine()?.lowercased() == "y"
            
            var deadline: Date? = nil
            if hasDeadline {
                print("Enter deadline (MM/DD/YYYY): ", terminator: "")
                if let deadlineStr = readLine() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    deadline = dateFormatter.date(from: deadlineStr)
                }
            }
            
            task = WorkTask(title: title, description: description, priority: priority, project: project, deadline: deadline)
        case 3:
            print("Enter location (optional): ", terminator: "")
            let location = readLine()
            
            task = PersonalTask(title: title, description: description, priority: priority, location: location)
        default:
            task = Task(title: title, description: description, priority: priority)
        }
        
        addTask(task)
    }
    
    // Helper method to update a task
    private func updateTask() {
        if tasks.isEmpty {
            print("No tasks available to update.")
            return
        }
        
        displayAllTasks()
        
        print("\nEnter the task number to update: ", terminator: "")
        guard let indexStr = readLine(), let index = Int(indexStr), (1...tasks.count).contains(index) else {
            print("Invalid task number.")
            return
        }
        
        let taskIndex = index - 1
        
        print("\n===== Update Task =====")
        print("1. Update status")
        print("2. Update title")
        print("3. Update description")
        print("4. Update priority")
        print("Enter your choice (1-4): ", terminator: "")
        
        guard let updateChoice = readLine(), let choice = Int(updateChoice), (1...4).contains(choice) else {
            print("Invalid choice. Returning to main menu.")
            return
        }
        
        switch choice {
        case 1:
            print("Select new status:")
            for (index, status) in TaskStatus.allCases.enumerated() {
                print("\(index + 1). \(status.rawValue)")
            }
            print("Enter your choice (1-3): ", terminator: "")
            
            if let statusChoice = readLine(), let statusIndex = Int(statusChoice), (1...TaskStatus.allCases.count).contains(statusIndex) {
                let status = TaskStatus.allCases[statusIndex - 1]
                tasks[taskIndex].updateStatus(to: status)
                print("Task status updated successfully!")
            } else {
                print("Invalid status choice.")
            }
        case 2:
            print("Enter new title: ", terminator: "")
            if let newTitle = readLine(), !newTitle.isEmpty {
                tasks[taskIndex].title = newTitle
                print("Task title updated successfully!")
            } else {
                print("Title cannot be empty.")
            }
        case 3:
            print("Enter new description: ", terminator: "")
            let newDescription = readLine() ?? ""
            tasks[taskIndex].description = newDescription
            print("Task description updated successfully!")
        case 4:
            print("Select new priority:")
            for (index, priority) in Priority.allCases.enumerated() {
                print("\(index + 1). \(priority.description)")
            }
            print("Enter your choice (1-3): ", terminator: "")
            
            if let priorityChoice = readLine(), let priorityIndex = Int(priorityChoice), (1...Priority.allCases.count).contains(priorityIndex) {
                let priority = Priority.allCases[priorityIndex - 1]
                tasks[taskIndex].priority = priority
                print("Task priority updated successfully!")
            } else {
                print("Invalid priority choice.")
            }
        default:
            print("Invalid choice.")
        }
    }
    
    // Helper method to delete a task
    private func deleteTask() {
        if tasks.isEmpty {
            print("No tasks available to delete.")
            return
        }
        
        displayAllTasks()
        
        print("\nEnter the task number to delete: ", terminator: "")
        if let indexStr = readLine(), let index = Int(indexStr), (1...tasks.count).contains(index) {
            removeTask(at: index - 1)
        } else {
            print("Invalid task number.")
        }
    }
    
    // Helper method to filter tasks
    private func filterTasks() {
        print("\n===== Filter Tasks =====")
        print("Select status to filter by:")
        for (index, status) in TaskStatus.allCases.enumerated() {
            print("\(index + 1). \(status.rawValue)")
        }
        print("Enter your choice (1-3): ", terminator: "")
        
        if let statusChoice = readLine(), let statusIndex = Int(statusChoice), (1...TaskStatus.allCases.count).contains(statusIndex) {
            let status = TaskStatus.allCases[statusIndex - 1]
            displayTasksByStatus(status)
        } else {
            print("Invalid status choice.")
        }
    }
}
