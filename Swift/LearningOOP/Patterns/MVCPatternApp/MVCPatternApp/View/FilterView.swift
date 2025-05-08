//
//  FilterView.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import SwiftUI

struct FilterView: View {
    @EnvironmentObject var taskController: TaskController
    @Environment(\.presentationMode) var presentationMode
    
    // Local state for filters
    @State private var localCategory: TaskCategory?
    @State private var localPriority: TaskPriority?
    @State private var localStatus: TaskStatus?
    @State private var localShowCompleted: Bool = true
    @State private var localSortOption: TaskController.SortOption = .dueDate
    
    var body: some View {
        NavigationView {
            Form {
                // Category filter
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $localCategory) {
                        Text("All Categories").tag(nil as TaskCategory?)
                        
                        ForEach(TaskCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category as TaskCategory?)
                        }
                    }
                }
                
                // Priority filter
                Section(header: Text("Priority")) {
                    Picker("Select Priority", selection: $localPriority) {
                        Text("All Priorities").tag(nil as TaskPriority?)
                        
                        ForEach(TaskPriority.allCases) { priority in
                            Text(priority.rawValue).tag(priority as TaskPriority?)
                        }
                    }
                }
                
                // Status filter
                Section(header: Text("Status")) {
                    Picker("Select Status", selection: $localStatus) {
                        Text("All Statuses").tag(nil as TaskStatus?)
                        
                        ForEach(TaskStatus.allCases) { status in
                            Text(status.rawValue).tag(status as TaskStatus?)
                        }
                    }
                    
                    Toggle("Show Completed Tasks", isOn: $localShowCompleted)
                }
                
                // Sort options
                Section(header: Text("Sort By")) {
                    Picker("Sort By", selection: $localSortOption) {
                        ForEach(TaskController.SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
                
                // Action buttons
                Section {
                    Button(action: applyFilters) {
                        Text("Apply Filters")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: resetFilters) {
                        Text("Reset Filters")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Filter Tasks")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                // Initialize local state with current filter values
                localCategory = taskController.selectedCategory
                localPriority = taskController.selectedPriority
                localStatus = taskController.selectedStatus
                localShowCompleted = taskController.showCompletedTasks
                localSortOption = taskController.sortOption
            }
        }
    }
    
    // Apply selected filters
    private func applyFilters() {
        taskController.selectedCategory = localCategory
        taskController.selectedPriority = localPriority
        taskController.selectedStatus = localStatus
        taskController.showCompletedTasks = localShowCompleted
        taskController.sortOption = localSortOption
        
        presentationMode.wrappedValue.dismiss()
    }
    
    // Reset all filters
    private func resetFilters() {
        localCategory = nil
        localPriority = nil
        localStatus = nil
        localShowCompleted = true
        localSortOption = .dueDate
        
        taskController.clearAllFilters()
        taskController.resetToDefaultSort()
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
            .environmentObject(TaskController())
    }
}
