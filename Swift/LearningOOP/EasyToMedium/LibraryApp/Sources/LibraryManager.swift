// LibraryManager.swift - Manages the collection of library items and user interaction

import Foundation

// LibraryManager class - demonstrates composition and collection management
class LibraryManager {
    // Array to store items - demonstrates collection usage
    private var items: [Item] = []
    
    // Method to add an item
    func addItem(_ item: Item) {
        items.append(item)
        print("Item added successfully!")
    }
    
    // Method to remove an item
    func removeItem(at index: Int) {
        guard index >= 0 && index < items.count else {
            print("Invalid item index!")
            return
        }
        
        items.remove(at: index)
        print("Item removed successfully!")
    }
    
    // Method to display all items
    func displayAllItems() {
        if items.isEmpty {
            print("No items available in the library.")
            return
        }
        
        print("\n===== Library Inventory =====")
        for (index, item) in items.enumerated() {
            print("\n--- Item #\(index + 1) ---")
            item.display()
        }
    }
    
    // Method to display items by status
    func displayItemsByStatus(_ status: ItemStatus) {
        let filteredItems = items.filter { $0.status == status }
        
        if filteredItems.isEmpty {
            print("No items with status: \(status.rawValue)")
            return
        }
        
        print("\n===== Items with Status: \(status.rawValue) =====")
        for (index, item) in filteredItems.enumerated() {
            print("\n--- Item #\(index + 1) ---")
            item.display()
        }
    }
    
    // Method to display items by type
    func displayItemsByType(_ type: ItemType) {
        let filteredItems = items.filter { $0.type == type }
        
        if filteredItems.isEmpty {
            print("No items of type: \(type.rawValue)")
            return
        }
        
        print("\n===== Items of Type: \(type.rawValue) =====")
        for (index, item) in filteredItems.enumerated() {
            print("\n--- Item #\(index + 1) ---")
            item.display()
        }
    }
    
    // Method to search items by title
    func searchItemsByTitle(_ searchTerm: String) {
        let filteredItems = items.filter { $0.title.lowercased().contains(searchTerm.lowercased()) }
        
        if filteredItems.isEmpty {
            print("No items found matching: \(searchTerm)")
            return
        }
        
        print("\n===== Search Results for: \(searchTerm) =====")
        for (index, item) in filteredItems.enumerated() {
            print("\n--- Item #\(index + 1) ---")
            item.display()
        }
    }
    
    // Main application loop
    func run() {
        print("Welcome to Library Management System!")
        
        var running = true
        while running {
            displayMenu()
            
            if let choice = readLine(), let option = Int(choice) {
                switch option {
                case 1:
                    addNewItem()
                case 2:
                    displayAllItems()
                case 3:
                    checkoutItem()
                case 4:
                    returnItem()
                case 5:
                    removeItemMenu()
                case 6:
                    searchItems()
                case 7:
                    filterItems()
                case 8:
                    running = false
                    print("Thank you for using Library Management System. Goodbye!")
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
        print("\n===== Library Management System Menu =====")
        print("1. Add a new item")
        print("2. Display all items")
        print("3. Checkout an item")
        print("4. Return an item")
        print("5. Remove an item")
        print("6. Search items")
        print("7. Filter items")
        print("8. Exit")
        print("Enter your choice (1-8): ", terminator: "")
    }
    
    // Helper method to add a new item
    private func addNewItem() {
        print("\n===== Add a New Item =====")
        print("Select item type:")
        for (index, type) in ItemType.allCases.enumerated() {
            print("\(index + 1). \(type.rawValue)")
        }
        print("Enter your choice (1-\(ItemType.allCases.count)): ", terminator: "")
        
        guard let typeChoice = readLine(), let itemType = Int(typeChoice), 
              (1...ItemType.allCases.count).contains(itemType) else {
            print("Invalid item type. Returning to main menu.")
            return
        }
        
        let selectedType = ItemType.allCases[itemType - 1]
        
        print("Enter item title: ", terminator: "")
        guard let title = readLine(), !title.isEmpty else {
            print("Title cannot be empty. Returning to main menu.")
            return
        }
        
        var item: Item
        
        switch selectedType {
        case .book:
            print("Enter author name: ", terminator: "")
            let author = readLine() ?? "Unknown"
            
            print("Enter number of pages: ", terminator: "")
            let pages = Int(readLine() ?? "0") ?? 0
            
            print("Enter genre: ", terminator: "")
            let genre = readLine() ?? "Unspecified"
            
            item = Book(title: title, author: author, pages: pages, genre: genre)
            
        case .dvd:
            print("Enter director name: ", terminator: "")
            let director = readLine() ?? "Unknown"
            
            print("Enter duration (in minutes): ", terminator: "")
            let duration = Int(readLine() ?? "0") ?? 0
            
            print("Enter release year: ", terminator: "")
            let releaseYear = Int(readLine() ?? "0") ?? 0
            
            item = DVD(title: title, director: director, duration: duration, releaseYear: releaseYear)
            
        case .magazine:
            print("Enter publisher: ", terminator: "")
            let publisher = readLine() ?? "Unknown"
            
            print("Enter issue date (MM/DD/YYYY): ", terminator: "")
            var issueDate = Date()
            if let dateStr = readLine() {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                issueDate = dateFormatter.date(from: dateStr) ?? Date()
            }
            
            item = Magazine(title: title, publisher: publisher, issueDate: issueDate)
            
        case .audiobook:
            // For simplicity, we'll treat audiobooks as regular items
            item = Item(title: title, type: .audiobook)
        }
        
        addItem(item)
    }
    
    // Helper method to checkout an item
    private func checkoutItem() {
        if items.isEmpty {
            print("No items available in the library.")
            return
        }
        
        // Display only available items
        let availableItems = items.filter { $0.status == .available }
        
        if availableItems.isEmpty {
            print("No items available for checkout.")
            return
        }
        
        print("\n===== Available Items =====")
        for (index, item) in availableItems.enumerated() {
            print("\(index + 1). \(item.title) (\(item.type.rawValue))")
        }
        
        print("\nEnter the item number to checkout: ", terminator: "")
        if let indexStr = readLine(), let index = Int(indexStr), (1...availableItems.count).contains(index) {
            availableItems[index - 1].checkout()
        } else {
            print("Invalid item number.")
        }
    }
    
    // Helper method to return an item
    private func returnItem() {
        if items.isEmpty {
            print("No items in the library.")
            return
        }
        
        // Display only borrowed items
        let borrowedItems = items.filter { $0.status == .borrowed }
        
        if borrowedItems.isEmpty {
            print("No items currently checked out.")
            return
        }
        
        print("\n===== Checked Out Items =====")
        for (index, item) in borrowedItems.enumerated() {
            print("\(index + 1). \(item.title) (\(item.type.rawValue))")
        }
        
        print("\nEnter the item number to return: ", terminator: "")
        if let indexStr = readLine(), let index = Int(indexStr), (1...borrowedItems.count).contains(index) {
            borrowedItems[index - 1].returnItem()
        } else {
            print("Invalid item number.")
        }
    }
    
    // Helper method to remove an item
    private func removeItemMenu() {
        if items.isEmpty {
            print("No items available to remove.")
            return
        }
        
        displayAllItems()
        
        print("\nEnter the item number to remove: ", terminator: "")
        if let indexStr = readLine(), let index = Int(indexStr), (1...items.count).contains(index) {
            removeItem(at: index - 1)
        } else {
            print("Invalid item number.")
        }
    }
    
    // Helper method to search items
    private func searchItems() {
        if items.isEmpty {
            print("No items in the library to search.")
            return
        }
        
        print("\n===== Search Items =====")
        print("Enter search term: ", terminator: "")
        
        if let searchTerm = readLine(), !searchTerm.isEmpty {
            searchItemsByTitle(searchTerm)
        } else {
            print("Search term cannot be empty.")
        }
    }
    
    // Helper method to filter items
    private func filterItems() {
        if items.isEmpty {
            print("No items in the library to filter.")
            return
        }
        
        print("\n===== Filter Items =====")
        print("Filter by:")
        print("1. Status")
        print("2. Type")
        print("Enter your choice (1-2): ", terminator: "")
        
        guard let filterChoice = readLine(), let choice = Int(filterChoice), (1...2).contains(choice) else {
            print("Invalid choice. Returning to main menu.")
            return
        }
        
        switch choice {
        case 1:
            print("\nSelect status to filter by:")
            for (index, status) in ItemStatus.allCases.enumerated() {
                print("\(index + 1). \(status.rawValue)")
            }
            print("Enter your choice (1-\(ItemStatus.allCases.count)): ", terminator: "")
            
            if let statusChoice = readLine(), let statusIndex = Int(statusChoice), 
               (1...ItemStatus.allCases.count).contains(statusIndex) {
                let status = ItemStatus.allCases[statusIndex - 1]
                displayItemsByStatus(status)
            } else {
                print("Invalid status choice.")
            }
            
        case 2:
            print("\nSelect type to filter by:")
            for (index, type) in ItemType.allCases.enumerated() {
                print("\(index + 1). \(type.rawValue)")
            }
            print("Enter your choice (1-\(ItemType.allCases.count)): ", terminator: "")
            
            if let typeChoice = readLine(), let typeIndex = Int(typeChoice), 
               (1...ItemType.allCases.count).contains(typeIndex) {
                let type = ItemType.allCases[typeIndex - 1]
                displayItemsByType(type)
            } else {
                print("Invalid type choice.")
            }
            
        default:
            print("Invalid choice.")
        }
    }
}
