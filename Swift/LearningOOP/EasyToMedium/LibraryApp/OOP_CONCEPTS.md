# Object-Oriented Programming Concepts in LibraryApp

This document explains the key Object-Oriented Programming (OOP) concepts demonstrated in the LibraryApp.

## 1. Classes and Objects

**Classes** are blueprints for creating objects, and **objects** are instances of classes.

- **Item** - Base class that defines the structure and behavior of a library item
- **Book**, **DVD**, and **Magazine** - Specialized item classes
- **LibraryManager** - Class that manages the collection of library items

Example in code:
```swift
// Class definition
class Item: ItemProtocol {
    var title: String
    let itemId: String
    // ...
}

// Object creation
let myBook = Book(title: "Swift Programming", author: "Apple Inc.", pages: 500, genre: "Programming")
```

## 2. Inheritance

**Inheritance** allows a class to inherit properties and methods from another class.

- **Book** inherits from **Item** and adds author, pages, and genre properties
- **DVD** inherits from **Item** and adds director, duration, and releaseYear properties
- **Magazine** inherits from **Item** and adds publisher and issueDate properties

Example in code:
```swift
// Base class
class Item: ItemProtocol {
    // Properties and methods
}

// Derived class
class Book: Item {
    var author: String
    var pages: Int
    var genre: String
    // Additional properties and methods
}
```

## 3. Polymorphism

**Polymorphism** allows objects of different classes to be treated as objects of a common superclass, with each responding appropriately to common methods.

- Each subclass (**Book**, **DVD**, **Magazine**) overrides the `display()` method to show its specific attributes
- The **LibraryManager** can work with any **Item** object regardless of its specific type

Example in code:
```swift
// Base class method
func display() {
    print("Title: \(title)")
    // ...
}

// Overridden method in derived class
override func display() {
    super.display() // Call parent method
    print("Author: \(author)") // Add specialized behavior
    // ...
}
```

## 4. Encapsulation

**Encapsulation** hides the internal state and requires all interaction to be performed through well-defined interfaces.

- Private properties in **LibraryManager** (like `items` array)
- Private helper methods that handle internal functionality
- Public methods that provide a clean interface for interacting with the class

Example in code:
```swift
class LibraryManager {
    // Private property - hidden from outside
    private var items: [Item] = []
    
    // Public method - accessible interface
    func addItem(_ item: Item) {
        items.append(item)
        print("Item added successfully!")
    }
}
```

## 5. Abstraction

**Abstraction** focuses on the essential qualities of an object rather than the specific details.

- The **ItemProtocol** defines what a library item should do without specifying how
- Implementation details are hidden from the user of the class

Example in code:
```swift
protocol ItemProtocol {
    var title: String { get set }
    var itemId: String { get }
    // Other properties
    
    func checkout()
    func returnItem()
    func reserve()
    func display()
}
```

## 6. Composition

**Composition** is a design principle that builds complex objects by combining simpler ones.

- **LibraryManager** contains a collection of **Item** objects
- This "has-a" relationship is different from inheritance's "is-a" relationship

Example in code:
```swift
class LibraryManager {
    private var items: [Item] = [] // LibraryManager has items
}
```

## 7. Enumerations

Swift's **enumerations** are first-class types that can have methods and computed properties.

- **ItemType** enum defines different types of library items
- **ItemStatus** enum defines possible item statuses

Example in code:
```swift
enum ItemType: String, CaseIterable {
    case book = "Book"
    case magazine = "Magazine"
    case dvd = "DVD"
    case audiobook = "Audiobook"
}
```

## Learning Exercises

1. Add a new item type (e.g., **Newspaper**)
2. Create a **Borrower** class to track who has borrowed items
3. Add a rating system for items
4. Implement a reservation system with waiting lists
5. Add search functionality by author, director, or genre
6. Create a reporting system to show library statistics
