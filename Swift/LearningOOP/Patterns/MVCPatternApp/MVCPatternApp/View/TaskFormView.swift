//
//  TaskFormView.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import SwiftUI

// Enum to determine if we're adding or editing a task
enum FormMode {
    case add
    case edit(Task)
}

struct TaskFormView: View {
    @EnvironmentObject var taskController: TaskController
    @Environment(\.presentationMode) var presentationMode
    
    let mode: FormMode
    
    // Form state
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: TaskCategory = .other
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedStatus: TaskStatus = .pending
    @State private var dueDate: Date = Date().addingTimeInterval(86400) // Tomorrow
    @State private var hasDueDate: Bool = true
    @State private var tags: String = ""
    
    // Task ID for edit mode
    private var taskId: UUID? {
        switch mode {
        case .add:
            return nil
        case .edit(let task):
            return task.id
        }
    }
    
    // Helper property to check if we're in add mode
    private var isAddMode: Bool {
        if case .add = mode {
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic information section
                Section(header: Text("Basic Information")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                // Category section
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                // Priority section
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.rawValue)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Status section (only for edit mode)
                if case .edit = mode {
                    Section(header: Text("Status")) {
                        Picker("Status", selection: $selectedStatus) {
                            ForEach(TaskStatus.allCases) { status in
                                Text(status.rawValue)
                                    .tag(status)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                // Due date section
                Section(header: Text("Due Date")) {
                    Toggle("Has Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker(
                            "Due Date",
                            selection: $dueDate,
                            displayedComponents: [.date]
                        )
                    }
                }
                
                // Tags section
                Section(header: Text("Tags")) {
                    TextField("Tags (comma separated)", text: $tags)
                }
                
                // Save button
                Section {
                    Button(action: saveTask) {
                        Text(isAddMode ? "Add Task" : "Update Task")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle(isAddMode ? "Add Task" : "Edit Task")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                setupInitialValues()
            }
        }
    }
    
    // Initialize form values based on mode
    private func setupInitialValues() {
        switch mode {
        case .add:
            // Default values already set
            break
        case .edit(let task):
            title = task.title
            description = task.description
            selectedCategory = task.category
            selectedPriority = task.priority
            selectedStatus = task.status
            hasDueDate = task.dueDate != nil
            if let dueDate = task.dueDate {
                self.dueDate = dueDate
            }
            tags = task.tags.joined(separator: ", ")
        }
    }
    
    // Save or update task
    private func saveTask() {
        // Validate input
        guard !title.isEmpty else { return }
        
        // Process tags
        let tagList = tags.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Create task object
        let task = Task(
            title: title,
            description: description,
            category: selectedCategory,
            priority: selectedPriority,
            dueDate: hasDueDate ? dueDate : nil,
            status: selectedStatus,
            tags: tagList
        )
        
        // Add or update task based on mode
        switch mode {
        case .add:
            taskController.addTask(task)
        case .edit:
            if let id = taskId {
                var updatedTask = task
                updatedTask.id = id
                taskController.updateTask(updatedTask)
            }
        }
        
        // Dismiss the form
        presentationMode.wrappedValue.dismiss()
    }
}

struct TaskFormView_Previews: PreviewProvider {
    static var previews: some View {
        TaskFormView(mode: .add)
            .environmentObject(TaskController())
    }
}
