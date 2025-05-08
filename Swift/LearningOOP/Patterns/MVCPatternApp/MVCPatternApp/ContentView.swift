//
//  ContentView.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var taskController: TaskController
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tasks List Tab
            NavigationView {
                TaskListView()
                    .navigationTitle("Tasks")
                    .navigationBarItems(
                        leading: FilterButton(),
                        trailing: AddTaskButton()
                    )
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            .tag(0)
            
            // Categories Tab
            NavigationView {
                CategoryListView()
                    .navigationTitle("Categories")
            }
            .tabItem {
                Label("Categories", systemImage: "folder")
            }
            .tag(1)
            
            // Statistics Tab
            NavigationView {
                StatisticsView()
                    .navigationTitle("Statistics")
            }
            .tabItem {
                Label("Statistics", systemImage: "chart.bar")
            }
            .tag(2)
            
            // Settings Tab
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
    }
}

// Filter Button Component
struct FilterButton: View {
    @EnvironmentObject var taskController: TaskController
    @State private var showingFilterSheet = false
    
    var body: some View {
        Button(action: {
            showingFilterSheet = true
        }) {
            Image(systemName: "line.horizontal.3.decrease.circle")
                .imageScale(.large)
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterView()
        }
    }
}

// Add Task Button Component
struct AddTaskButton: View {
    @State private var showingAddTaskSheet = false
    
    var body: some View {
        Button(action: {
            showingAddTaskSheet = true
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
        .sheet(isPresented: $showingAddTaskSheet) {
            TaskFormView(mode: .add)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TaskController())
    }
}

