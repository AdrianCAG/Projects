# Object-Oriented Programming Concepts in TaskManagerApp

This document explains the key Object-Oriented Programming (OOP) concepts demonstrated in the TaskManagerApp.

## 1. Classes and Objects

**Classes** are blueprints for creating objects, and **objects** are instances of classes.

- **Task** - Base class that defines the structure and behavior of a task
- **WorkTask** and **PersonalTask** - Specialized task classes
- **TaskManager** - Class that manages the collection of tasks

Example in code:
```swift
// Class definition
class Task: TaskProtocol {
    var title: String
    var description: String
    // ...
}

// Object creation
let myTask = Task(title: "Learn Swift", description: "Study Swift programming")
```

## 2. Inheritance

**Inheritance** allows a class to inherit properties and methods from another class.

- **WorkTask** inherits from **Task** and adds project and deadline properties
- **PersonalTask** inherits from **Task** and adds location property

Example in code:
```swift
// Base class
class Task: TaskProtocol {
    // Properties and methods
}

// Derived class
class WorkTask: Task {
    var project: String
    var deadline: Date?
    // Additional properties and methods
}
```

## 3. Polymorphism

**Polymorphism** allows objects of different classes to be treated as objects of a common superclass, with each responding appropriately to common methods.

- Both **WorkTask** and **PersonalTask** override the `display()` method to show their specific attributes
- The **TaskManager** can work with any **Task** object regardless of its specific type

Example in code:
```swift
// Base class method
func display() {
    print("Task: \(title)")
    // ...
}

// Overridden method in derived class
override func display() {
    super.display() // Call parent method
    print("Project: \(project)") // Add specialized behavior
    // ...
}
```

## 4. Encapsulation

**Encapsulation** hides the internal state and requires all interaction to be performed through well-defined interfaces.

- Private properties in **TaskManager** (like `tasks` array)
- Private helper methods that handle internal functionality
- Public methods that provide a clean interface for interacting with the class

Example in code:
```swift
class TaskManager {
    // Private property - hidden from outside
    private var tasks: [Task] = []
    
    // Public method - accessible interface
    func addTask(_ task: Task) {
        tasks.append(task)
        print("Task added successfully!")
    }
}
```

## 5. Abstraction

**Abstraction** focuses on the essential qualities of an object rather than the specific details.

- The **TaskProtocol** defines what a task should do without specifying how
- Implementation details are hidden from the user of the class

Example in code:
```swift
protocol TaskProtocol {
    var title: String { get set }
    // Other properties
    
    func markAsCompleted()
    func updateStatus(to status: TaskStatus)
    func display()
}
```

## 6. Composition

**Composition** is a design principle that builds complex objects by combining simpler ones.

- **TaskManager** contains a collection of **Task** objects
- This "has-a" relationship is different from inheritance's "is-a" relationship

Example in code:
```swift
class TaskManager {
    private var tasks: [Task] = [] // TaskManager has tasks
}
```

## 7. Enumerations

Swift's **enumerations** are first-class types that can have methods and computed properties.

- **Priority** enum defines task priority levels
- **TaskStatus** enum defines possible task statuses

Example in code:
```swift
enum Priority: Int, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    
    var description: String {
        switch self {
        case .low: return "Low"
        // ...
        }
    }
}
```

## Learning Exercises

1. Add a new task type (e.g., **StudyTask**)
2. Add a new property to an existing class
3. Implement a new feature (e.g., task categories)
4. Create a method to find tasks by keyword
5. Add the ability to set task due dates
