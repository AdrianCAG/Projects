# MVC Pattern App

A Swift iOS application that demonstrates the Model-View-Controller (MVC) architectural pattern through a comprehensive task management system.

## Overview

This application is a feature-rich task management system that allows users to create, organize, and track tasks across different categories and priorities. It serves as a practical demonstration of the MVC architectural pattern, showing how to properly separate concerns in an iOS application.

## Design Pattern: Model-View-Controller (MVC)

The Model-View-Controller (MVC) pattern is one of the most fundamental architectural patterns in software development. It divides an application into three interconnected components to separate internal representations of information from the ways information is presented to and accepted from the user.

### Key Components in This Implementation

1. **Model**: Represents the application's data and business logic
   - `Task`: Core data model representing a task with properties and computed values
   - `TaskCategory`, `TaskPriority`, `TaskStatus`: Enums that define task attributes
   
2. **View**: Represents the UI elements that display data to the user and capture user interactions
   - `TaskListView`: Displays the list of tasks
   - `TaskDetailView`: Shows detailed information about a specific task
   - `TaskFormView`: Allows creating and editing tasks
   - Various supporting views like `TaskRowView`, `FilterView`, etc.
   
3. **Controller**: Acts as an intermediary between Model and View
   - `TaskController`: Manages task data and provides methods for the views to interact with the data
   - Handles filtering, sorting, and CRUD operations on tasks

## Project Structure

```
MVCPatternApp/
├── Model/
│   ├── Task.swift                 # Core data model
│   └── TaskStore.swift            # Data persistence
├── View/
│   ├── TaskListView.swift         # Main task list
│   ├── TaskDetailView.swift       # Task details
│   ├── TaskFormView.swift         # Create/edit form
│   ├── TaskRowView.swift          # Individual task row
│   ├── FilterView.swift           # Filtering options
│   ├── SortView.swift             # Sorting options
│   └── EmptyStateView.swift       # Empty state UI
├── Controller/
│   └── TaskController.swift       # Business logic
├── ContentView.swift              # Main app view
└── MVCPatternAppApp.swift         # App entry point
```

## Features

- Create, read, update, and delete tasks
- Categorize tasks (Personal, Work, Health, etc.)
- Set task priorities (Low, Medium, High, Urgent)
- Track task status (Pending, In Progress, Completed, Cancelled)
- Add due dates and tags to tasks
- Filter tasks by category, priority, and status
- Search tasks by title or description
- Sort tasks by various criteria (due date, priority, title, etc.)
- View task statistics and progress
- Get notifications for upcoming and overdue tasks

## How the MVC Pattern is Applied

### Model Layer
- The `Task` struct represents the core data model with properties like title, description, category, priority, etc.
- Supporting enums (`TaskCategory`, `TaskPriority`, `TaskStatus`) define the possible values for task attributes
- The model contains business logic like determining if a task is overdue or calculating days remaining

### View Layer
- SwiftUI views that display the UI and capture user interactions
- Views are kept "dumb" - they don't contain business logic
- Views observe the controller using SwiftUI's `@EnvironmentObject` and `@ObservedObject` property wrappers
- When user interactions occur, views call methods on the controller

### Controller Layer
- The `TaskController` class acts as an intermediary between the model and view
- It's responsible for:
  - Loading and saving tasks
  - Filtering and sorting tasks based on user criteria
  - Handling CRUD operations (create, read, update, delete)
  - Notifying views of changes to the data
- The controller conforms to `ObservableObject` so views can observe changes

## Benefits of the MVC Pattern

1. **Separation of Concerns**: Each component has a specific responsibility, making the code more organized and maintainable
2. **Code Reusability**: Models and controllers can be reused across different views
3. **Parallel Development**: Different team members can work on different components simultaneously
4. **Testability**: Each component can be tested in isolation
5. **Flexibility**: Changes to one component have minimal impact on others

## Running the Application

To run the application:

1. Open the `MVCPatternApp.xcodeproj` file in Xcode
2. Select a simulator or connected device
3. Press the Run button (⌘+R)

## Usage Example

The application allows you to:

1. View all your tasks organized by due date, category, or priority
2. Add new tasks with detailed information
3. Edit existing tasks to update their status or details
4. Filter and search for specific tasks
5. Track your progress with statistics and visualizations

## Implementation Details

- Built with SwiftUI for the user interface
- Uses Combine framework for reactive programming
- Implements UserDefaults for simple data persistence
- Follows Apple's Human Interface Guidelines for a native iOS experience
- Uses Swift's strong type system to ensure data integrity
