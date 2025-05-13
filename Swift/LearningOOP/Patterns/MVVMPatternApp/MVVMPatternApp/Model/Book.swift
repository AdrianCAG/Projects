//
//  Book.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import Foundation

// MARK: - Enums for Book attributes

enum BookGenre: String, CaseIterable, Identifiable, Codable {
    case fiction = "Fiction"
    case nonFiction = "Non-Fiction"
    case fantasy = "Fantasy"
    case sciFi = "Science Fiction"
    case mystery = "Mystery"
    case thriller = "Thriller"
    case biography = "Biography"
    case history = "History"
    case selfHelp = "Self-Help"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .fiction: return "book.fill"
        case .nonFiction: return "doc.text.fill"
        case .fantasy: return "wand.and.stars"
        case .sciFi: return "star.fill"
        case .mystery: return "magnifyingglass"
        case .thriller: return "bolt.fill"
        case .biography: return "person.fill"
        case .history: return "clock.fill"
        case .selfHelp: return "hand.raised.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

enum ReadingStatus: String, CaseIterable, Identifiable, Codable {
    case unread = "Unread"
    case inProgress = "In Progress"
    case completed = "Completed"
    case abandoned = "Abandoned"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .unread: return "book.closed.fill"
        case .inProgress: return "book.fill"
        case .completed: return "checkmark.circle.fill"
        case .abandoned: return "xmark.circle.fill"
        }
    }
}

enum BookFormat: String, CaseIterable, Identifiable, Codable {
    case hardcover = "Hardcover"
    case paperback = "Paperback"
    case ebook = "E-Book"
    case audiobook = "Audiobook"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .hardcover: return "book.fill"
        case .paperback: return "book"
        case .ebook: return "ipad"
        case .audiobook: return "headphones"
        }
    }
}

// MARK: - Book Model

struct Book: Identifiable, Codable {
    var id: UUID
    var title: String
    var author: String
    var genre: BookGenre
    var status: ReadingStatus
    var format: BookFormat
    var publicationDate: Date?
    var rating: Int? // 1-5 stars
    var notes: String
    var dateAdded: Date
    var lastUpdated: Date
    var coverImageName: String? // For storing image references
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        genre: BookGenre = .fiction,
        status: ReadingStatus = .unread,
        format: BookFormat = .paperback,
        publicationDate: Date? = nil,
        rating: Int? = nil,
        notes: String = "",
        coverImageName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.genre = genre
        self.status = status
        self.format = format
        self.publicationDate = publicationDate
        self.rating = rating
        self.notes = notes
        self.coverImageName = coverImageName
        self.dateAdded = Date()
        self.lastUpdated = Date()
    }
    
    // MARK: - Computed Properties
    
    var isRead: Bool {
        return status == .completed
    }
    
    var isInProgress: Bool {
        return status == .inProgress
    }
    
    var formattedPublicationDate: String {
        guard let date = publicationDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedDateAdded: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateAdded)
    }
    
    // For display purposes
    var ratingText: String {
        guard let rating = rating else { return "Not rated" }
        let stars = String(repeating: "★", count: rating)
        let emptyStars = String(repeating: "☆", count: 5 - rating)
        return stars + emptyStars
    }
    
    // MARK: - Mutating Methods
    
    mutating func markAsRead() {
        self.status = .completed
        self.lastUpdated = Date()
    }
    
    mutating func markAsInProgress() {
        self.status = .inProgress
        self.lastUpdated = Date()
    }
    
    mutating func markAsAbandoned() {
        self.status = .abandoned
        self.lastUpdated = Date()
    }
    
    mutating func update(
        title: String? = nil,
        author: String? = nil,
        genre: BookGenre? = nil,
        status: ReadingStatus? = nil,
        format: BookFormat? = nil,
        publicationDate: Date? = nil,
        rating: Int? = nil,
        notes: String? = nil,
        coverImageName: String? = nil
    ) {
        if let title = title { self.title = title }
        if let author = author { self.author = author }
        if let genre = genre { self.genre = genre }
        if let status = status { self.status = status }
        if let format = format { self.format = format }
        if let publicationDate = publicationDate { self.publicationDate = publicationDate }
        if let rating = rating { self.rating = rating }
        if let notes = notes { self.notes = notes }
        if let coverImageName = coverImageName { self.coverImageName = coverImageName }
        self.lastUpdated = Date()
    }
}

// MARK: - Book Extension for Sample Data

extension Book {
    static var sampleBooks: [Book] {
        [
            Book(
                title: "The Swift Programming Language",
                author: "Apple Inc.",
                genre: .nonFiction,
                status: .inProgress,
                format: .ebook,
                publicationDate: Calendar.current.date(from: DateComponents(year: 2014, month: 6, day: 2)),
                rating: 5,
                notes: "Essential reading for Swift development.",
                coverImageName: "swift_book"
            ),
            Book(
                title: "1984",
                author: "George Orwell",
                genre: .fiction,
                status: .completed,
                format: .paperback,
                publicationDate: Calendar.current.date(from: DateComponents(year: 1949, month: 6, day: 8)),
                rating: 5,
                notes: "A classic dystopian novel that remains relevant today.",
                coverImageName: "1984"
            ),
            Book(
                title: "The Hobbit",
                author: "J.R.R. Tolkien",
                genre: .fantasy,
                status: .completed,
                format: .hardcover,
                publicationDate: Calendar.current.date(from: DateComponents(year: 1937, month: 9, day: 21)),
                rating: 4,
                notes: "Charming adventure that precedes the Lord of the Rings trilogy.",
                coverImageName: "hobbit"
            ),
            Book(
                title: "Dune",
                author: "Frank Herbert",
                genre: .sciFi,
                status: .unread,
                format: .paperback,
                publicationDate: Calendar.current.date(from: DateComponents(year: 1965, month: 8, day: 1)),
                notes: "Science fiction classic that I've been meaning to read.",
                coverImageName: "dune"
            ),
            Book(
                title: "Atomic Habits",
                author: "James Clear",
                genre: .selfHelp,
                status: .inProgress,
                format: .audiobook,
                publicationDate: Calendar.current.date(from: DateComponents(year: 2018, month: 10, day: 16)),
                rating: 4,
                notes: "Great insights on building positive habits.",
                coverImageName: "atomic_habits"
            )
        ]
    }
}
