//
//  TaskListView.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskController: TaskController
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            // Search bar
            SearchBar(text: $searchText)
                .padding(.horizontal)
            
            if taskController.filteredTasks.isEmpty {
                // Empty state
                EmptyStateView()
            } else {
                // Task list
                List {
                    // Today's tasks section
                    if !taskController.tasksDueToday().isEmpty {
                        Section(header: Text("Today")) {
                            ForEach(taskController.tasksDueToday()) { task in
                                TaskRowView(task: task)
                            }
                        }
                    }
                    
                    // This week's tasks section
                    if !taskController.tasksDueThisWeek().isEmpty {
                        Section(header: Text("This Week")) {
                            ForEach(taskController.tasksDueThisWeek().filter { weekTask in
                                !taskController.tasksDueToday().contains { todayTask in todayTask.id == weekTask.id }
                            }) { task in
                                TaskRowView(task: task)
                            }
                        }
                    }
                    
                    // Other tasks section
                    Section(header: Text("All Tasks")) {
                        ForEach(taskController.filteredTasks.filter { task in
                            !taskController.tasksDueToday().contains { todayTask in todayTask.id == task.id } &&
                            !taskController.tasksDueThisWeek().contains { weekTask in weekTask.id == task.id }
                        }) { task in
                            TaskRowView(task: task)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
}

// Empty state view when no tasks are available
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 85))
                .foregroundColor(.gray)
            
            Text("No Tasks")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Add a new task to get started")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Search bar component
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search tasks...", text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Task row component
struct TaskRowView: View {
    @EnvironmentObject var taskController: TaskController
    let task: Task
    @State private var showingTaskDetail = false
    
    var body: some View {
        Button(action: {
            showingTaskDetail = true
        }) {
            HStack {
                // Task status indicator
                StatusIndicator(status: task.status)
                
                // Task details
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .fontWeight(.medium)
                        .strikethrough(task.status == .completed)
                        .foregroundColor(task.status == .completed ? .gray : .primary)
                    
                    HStack {
                        // Category badge
                        HStack(spacing: 4) {
                            Image(systemName: task.category.icon)
                                .font(.caption)
                            Text(task.category.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        
                        // Priority badge
                        PriorityBadge(priority: task.priority)
                        
                        // Due date if available
                        if let dueDate = task.dueDate {
                            Spacer()
                            Text(dueDateText(dueDate))
                                .font(.caption)
                                .foregroundColor(task.isOverdue ? .red : .gray)
                        }
                    }
                }
                
                Spacer()
                
                // Quick complete button
                if task.status != .completed {
                    Button(action: {
                        taskController.markTaskAsCompleted(id: task.id)
                    }) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showingTaskDetail) {
            TaskDetailView(task: task)
        }
    }
    
    // Helper to format due date
    private func dueDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Status indicator component
struct StatusIndicator: View {
    let status: TaskStatus
    
    var body: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 12, height: 12)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return .yellow
        case .inProgress:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .gray
        }
    }
}

// Priority badge component
struct PriorityBadge: View {
    let priority: TaskPriority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .cornerRadius(8)
    }
    
    private var priorityColor: Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .blue
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
}

//struct TaskListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskListView()
//            .environmentObject(TaskController())
//    }
//}
