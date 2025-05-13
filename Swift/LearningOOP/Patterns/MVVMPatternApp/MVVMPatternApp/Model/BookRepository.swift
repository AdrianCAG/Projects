//
//  BookRepository.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import Foundation
import Combine

// MARK: - Book Repository Protocol

/// Protocol defining the repository interface for book data operations
protocol BookRepositoryProtocol {
    func getBooks() -> [Book]
    func addBook(_ book: Book)
    func updateBook(_ book: Book)
    func deleteBook(withId id: UUID)
    func getBook(withId id: UUID) -> Book?
    func saveBooks()
}

// MARK: - Book Repository Implementation

/// Repository class responsible for data access and persistence
class BookRepository: BookRepositoryProtocol {
    // Singleton instance for app-wide access
    static let shared = BookRepository()
    
    // Storage for books
    private var books: [Book] = []
    
    // UserDefaults key for storing books
    private let booksKey = "SavedBooks"
    
    // MARK: - Initialization
    
    private init() {
        loadBooks()
        
        // If no books were loaded, use sample data
        if books.isEmpty {
            books = Book.sampleBooks
            saveBooks()
        }
    }
    
    // MARK: - Data Operations
    
    /// Retrieves all books from the repository
    func getBooks() -> [Book] {
        return books
    }
    
    /// Adds a new book to the repository
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    /// Updates an existing book in the repository
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }
    
    /// Deletes a book from the repository
    func deleteBook(withId id: UUID) {
        books.removeAll { $0.id == id }
        saveBooks()
    }
    
    /// Retrieves a specific book by ID
    func getBook(withId id: UUID) -> Book? {
        return books.first { $0.id == id }
    }
    
    // MARK: - Data Persistence
    
    /// Loads books from UserDefaults
    private func loadBooks() {
        guard let data = UserDefaults.standard.data(forKey: booksKey) else { return }
        
        let decoder = JSONDecoder()
        do {
            books = try decoder.decode([Book].self, from: data)
        } catch {
            print("Error decoding books: \(error.localizedDescription)")
        }
    }
    
    /// Saves books to UserDefaults
    func saveBooks() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(books)
            UserDefaults.standard.set(data, forKey: booksKey)
        } catch {
            print("Error encoding books: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Gets books filtered by genre
    func getBooks(byGenre genre: BookGenre) -> [Book] {
        return books.filter { $0.genre == genre }
    }
    
    /// Gets books filtered by reading status
    func getBooks(byStatus status: ReadingStatus) -> [Book] {
        return books.filter { $0.status == status }
    }
    
    /// Gets books filtered by format
    func getBooks(byFormat format: BookFormat) -> [Book] {
        return books.filter { $0.format == format }
    }
    
    /// Gets books that match a search query in title or author
    func searchBooks(query: String) -> [Book] {
        let lowercasedQuery = query.lowercased()
        return books.filter {
            $0.title.lowercased().contains(lowercasedQuery) ||
            $0.author.lowercased().contains(lowercasedQuery)
        }
    }
    
    /// Gets book count by genre
    func bookCount(byGenre genre: BookGenre) -> Int {
        return books.filter { $0.genre == genre }.count
    }
    
    /// Gets book count by reading status
    func bookCount(byStatus status: ReadingStatus) -> Int {
        return books.filter { $0.status == status }.count
    }
}
