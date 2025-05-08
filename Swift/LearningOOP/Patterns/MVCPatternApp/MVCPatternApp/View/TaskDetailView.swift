//
//  TaskDetailView.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var taskController: TaskController
    @Environment(\.presentationMode) var presentationMode
    
    let task: Task
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with title and status
                HStack {
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            StatusBadge(status: task.status)
                            
                            if task.isOverdue {
                                Text("Overdue")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Quick action buttons
                    if task.status != .completed {
                        Button(action: {
                            taskController.markTaskAsCompleted(id: task.id)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.bottom)
                
                // Description section
                if !task.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(task.description)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom)
                }
                
                // Details section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.headline)
                    
                    DetailRow(icon: task.category.icon, label: "Category", value: task.category.rawValue)
                    
                    DetailRow(icon: "exclamationmark.triangle", label: "Priority", value: task.priority.rawValue)
                    
                    if let dueDate = task.dueDate {
                        DetailRow(icon: "calendar", label: "Due Date", value: formatDate(dueDate))
                    }
                    
                    DetailRow(icon: "clock", label: "Created", value: formatDate(task.creationDate))
                    
                    if let completionDate = task.completionDate {
                        DetailRow(icon: "checkmark.circle", label: "Completed", value: formatDate(completionDate))
                    }
                }
                .padding(.bottom)
                
                // Tags section
                if !task.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(task.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            trailing: HStack {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("Edit")
                }
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        )
        .sheet(isPresented: $showingEditSheet) {
            TaskFormView(mode: .edit(task))
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Task"),
                message: Text("Are you sure you want to delete this task? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    taskController.deleteTask(withId: task.id)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // Helper to format dates
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Status badge component
struct StatusBadge: View {
    let status: TaskStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
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

// Detail row component
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            Text(label)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TaskDetailView(task: Task(
                title: "Sample Task",
                description: "This is a sample task description",
                category: .work,
                priority: .high,
                dueDate: Date().addingTimeInterval(86400),
                status: .inProgress,
                tags: ["sample", "preview"]
            ))
            .environmentObject(TaskController())
        }
    }
}
