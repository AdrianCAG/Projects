//
//  SettingsView.swift
//  MVCPatternApp
//
//  Created by Adrian on 5/8/25.
//

import SwiftUI

// Main Settings View
struct SettingsView: View {
    @EnvironmentObject var taskController: TaskController
    @State private var showingConfirmationDialog = false
    @State private var showingAboutSheet = false
    
    // App theme settings
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("accentColor") private var accentColorString = "blue"
    
    // Notification settings
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("notifyBeforeDueDate") private var notifyBeforeDueDate = true
    @AppStorage("notificationHours") private var notificationHours = 24
    
    // Available accent colors
    private let accentColors = [
        "blue": Color.blue,
        "green": Color.green,
        "purple": Color.purple,
        "orange": Color.orange,
        "pink": Color.pink
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Appearance section
                    AppearanceSection(isDarkMode: $isDarkMode, accentColorString: $accentColorString, accentColors: accentColors)
                    
                    // Notifications section
                    NotificationsSection(enableNotifications: $enableNotifications, notifyBeforeDueDate: $notifyBeforeDueDate, notificationHours: $notificationHours)
                    
                    // Data management section
                    DataManagementSection(taskController: taskController, showingConfirmationDialog: $showingConfirmationDialog)
                    
                    // About section
                    AboutSection(showingAboutSheet: $showingAboutSheet)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Settings")
        }
    }
}

// Appearance Section Component
struct AppearanceSection: View {
    @Binding var isDarkMode: Bool
    @Binding var accentColorString: String
    let accentColors: [String: Color]
    
    var body: some View {
        GroupBox(label: Text("Appearance").font(.headline)) {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Dark Mode", isOn: $isDarkMode)
                
                Text("Accent Color")
                Picker("Accent Color", selection: $accentColorString) {
                    ForEach(Array(accentColors.keys.sorted()), id: \.self) { key in
                        HStack {
                            Circle()
                                .fill(accentColors[key] ?? .blue)
                                .frame(width: 20, height: 20)
                            Text(key.capitalized)
                        }
                        .tag(key)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden()
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

// Notifications Section Component
struct NotificationsSection: View {
    @Binding var enableNotifications: Bool
    @Binding var notifyBeforeDueDate: Bool
    @Binding var notificationHours: Int
    
    var body: some View {
        GroupBox(label: Text("Notifications").font(.headline)) {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Enable Notifications", isOn: $enableNotifications)
                
                if enableNotifications {
                    Toggle("Notify Before Due Date", isOn: $notifyBeforeDueDate)
                    
                    if notifyBeforeDueDate {
                        Stepper(value: $notificationHours, in: 1...72) {
                            Text("Notify \(notificationHours) hours before")
                        }
                    }
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

// Data Management Section Component
struct DataManagementSection: View {
    let taskController: TaskController
    @Binding var showingConfirmationDialog: Bool
    
    var body: some View {
        GroupBox(label: Text("Data Management").font(.headline)) {
            VStack(alignment: .leading, spacing: 10) {
                Button(action: {
                    showingConfirmationDialog = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Clear All Tasks")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .alert(isPresented: $showingConfirmationDialog) {
                    Alert(
                        title: Text("Clear All Tasks"),
                        message: Text("Are you sure you want to delete all tasks? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete All")) {
                            // In a real implementation, this would clear all tasks
                            // For this demo, we'll just reset the filters
                            taskController.clearAllFilters()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                Button(action: {
                    taskController.addSampleTasks()
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                        Text("Add Sample Tasks")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

// About Section Component
struct AboutSection: View {
    @Binding var showingAboutSheet: Bool
    
    var body: some View {
        GroupBox(label: Text("About").font(.headline)) {
            VStack(alignment: .leading, spacing: 10) {
                Button(action: {
                    showingAboutSheet = true
                }) {
                    Text("About This App")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .sheet(isPresented: $showingAboutSheet) {
                    AboutView()
                }
                
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

// About view
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    Text("MVC Pattern App")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .foregroundColor(.gray)
                    
                    Divider()
                        .padding(.horizontal, 40)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("About")
                            .font(.headline)
                        
                        Text("This app demonstrates the Model-View-Controller (MVC) architectural pattern using SwiftUI for the view layer. It's a task management system that allows users to create, organize, and track tasks across different categories with various priorities and due dates.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("MVC Architecture")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("• Model: Represents the data and business logic")
                        Text("• View: Implemented with SwiftUI for the UI")
                        Text("• Controller: Mediates between Model and View")
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("About", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Extension to add the ability to observe changes to AppStorage values
extension View {
    func onChange<Value: Equatable>(of value: Value, perform action: @escaping (Value) -> Void) -> some View {
        OnChange(value: value, action: action, content: self)
    }
}

// Helper view for onChange
struct OnChange<Value: Equatable, Content: View>: View {
    let value: Value
    let action: (Value) -> Void
    let content: Content
    @State private var oldValue: Value
    
    init(value: Value, action: @escaping (Value) -> Void, content: Content) {
        self.value = value
        self.action = action
        self.content = content
        self._oldValue = State(initialValue: value)
    }
    
    var body: some View {
        content
            .onAppear {
                if oldValue != value {
                    oldValue = value
                    action(value)
                }
            }
            .onReceive(Just(value)) { newValue in
                if oldValue != newValue {
                    oldValue = newValue
                    action(newValue)
                }
            }
    }
}

// Add Combine for Just
import Combine

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//            .environmentObject(TaskController())
//    }
//}
