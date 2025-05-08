// Item.swift - Defines the Item class and related protocols/subclasses

import Foundation

// ItemType enum - demonstrates enumeration in Swift
enum ItemType: String, CaseIterable {
    case book = "Book"
    case magazine = "Magazine"
    case dvd = "DVD"
    case audiobook = "Audiobook"
}

// ItemStatus enum - demonstrates enumeration in Swift
enum ItemStatus: String, CaseIterable {
    case available = "Available"
    case borrowed = "Borrowed"
    case reserved = "Reserved"
    case maintenance = "Under Maintenance"
}

// Item Protocol - demonstrates protocol/interface concept
protocol ItemProtocol {
    var title: String { get set }
    var itemId: String { get }
    var type: ItemType { get }
    var status: ItemStatus { get set }
    var addedDate: Date { get }
    
    func checkout()
    func returnItem()
    func reserve()
    func display()
}

// Base Item class - demonstrates encapsulation
class Item: ItemProtocol {
    var title: String
    let itemId: String
    let type: ItemType
    var status: ItemStatus
    let addedDate: Date
    
    // Initializer (constructor)
    init(title: String, type: ItemType) {
        self.title = title
        self.type = type
        self.status = .available
        self.addedDate = Date()
        
        // Generate a unique ID based on type and timestamp
        let timestamp = Int(Date().timeIntervalSince1970)
        self.itemId = "\(type.rawValue.prefix(1))\(timestamp)"
    }
    
    // Method implementation
    func checkout() {
        if status == .available {
            status = .borrowed
            print("\(title) has been checked out.")
        } else {
            print("This item is not available for checkout.")
        }
    }
    
    // Method implementation
    func returnItem() {
        if status == .borrowed {
            status = .available
            print("\(title) has been returned.")
        } else {
            print("This item was not checked out.")
        }
    }
    
    // Method implementation
    func reserve() {
        if status == .available {
            status = .reserved
            print("\(title) has been reserved.")
        } else {
            print("This item is not available for reservation.")
        }
    }
    
    // Method implementation
    func display() {
        print("Title: \(title)")
        print("ID: \(itemId)")
        print("Type: \(type.rawValue)")
        print("Status: \(status.rawValue)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        print("Added on: \(dateFormatter.string(from: addedDate))")
    }
}

// Book class - demonstrates inheritance
class Book: Item {
    var author: String
    var pages: Int
    var genre: String
    
    init(title: String, author: String, pages: Int, genre: String) {
        self.author = author
        self.pages = pages
        self.genre = genre
        super.init(title: title, type: .book)
    }
    
    // Method overriding - demonstrates polymorphism
    override func display() {
        super.display()
        print("Author: \(author)")
        print("Pages: \(pages)")
        print("Genre: \(genre)")
    }
}

// DVD class - demonstrates inheritance
class DVD: Item {
    var director: String
    var duration: Int // in minutes
    var releaseYear: Int
    
    init(title: String, director: String, duration: Int, releaseYear: Int) {
        self.director = director
        self.duration = duration
        self.releaseYear = releaseYear
        super.init(title: title, type: .dvd)
    }
    
    // Method overriding - demonstrates polymorphism
    override func display() {
        super.display()
        print("Director: \(director)")
        print("Duration: \(duration) minutes")
        print("Release Year: \(releaseYear)")
    }
}

// Magazine class - demonstrates inheritance
class Magazine: Item {
    var publisher: String
    var issueDate: Date
    
    init(title: String, publisher: String, issueDate: Date) {
        self.publisher = publisher
        self.issueDate = issueDate
        super.init(title: title, type: .magazine)
    }
    
    // Method overriding - demonstrates polymorphism
    override func display() {
        super.display()
        print("Publisher: \(publisher)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        print("Issue Date: \(dateFormatter.string(from: issueDate))")
    }
}
