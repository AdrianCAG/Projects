//
//  BookDetailViewModel.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import Foundation
import Combine

/// ViewModel for managing the book detail view
class BookDetailViewModel: ObservableObject {
    // Published properties will automatically notify the view of changes
    @Published var book: Book?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Repository reference
    private let repository: BookRepositoryProtocol
    
    // MARK: - Initialization
    
    init(bookId: UUID? = nil, repository: BookRepositoryProtocol = BookRepository.shared) {
        self.repository = repository
        
        if let id = bookId {
            loadBook(id: id)
        }
    }
    
    // MARK: - Data Loading
    
    /// Loads a book by its ID
    func loadBook(id: UUID) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay (for educational purposes)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if let loadedBook = self.repository.getBook(withId: id) {
                self.book = loadedBook
            } else {
                self.errorMessage = "Could not find book with ID: \(id)"
            }
            
            self.isLoading = false
        }
    }
    
    // MARK: - Book Actions
    
    /// Updates the reading status of the book
    func updateReadingStatus(_ status: ReadingStatus) {
        guard var updatedBook = book else { return }
        
        updatedBook.update(status: status)
        repository.updateBook(updatedBook)
        book = updatedBook
    }
    
    /// Updates the user's rating of the book
    func updateRating(_ rating: Int) {
        guard var updatedBook = book, (1...5).contains(rating) else { return }
        
        updatedBook.update(rating: rating)
        repository.updateBook(updatedBook)
        book = updatedBook
    }
    
    /// Updates the notes for the book
    func updateNotes(_ notes: String) {
        guard var updatedBook = book else { return }
        
        updatedBook.update(notes: notes)
        repository.updateBook(updatedBook)
        book = updatedBook
    }
    
    /// Deletes the current book
    func deleteBook() -> Bool {
        guard let book = book else { return false }
        
        repository.deleteBook(withId: book.id)
        return true
    }
    
    // MARK: - Computed Properties
    
    /// User-friendly text for reading status
    var readingStatusText: String {
        book?.status.rawValue ?? "Unknown"
    }
    
    /// Icon name for reading status
    var readingStatusIcon: String {
        book?.status.iconName ?? "questionmark.circle"
    }
    
    /// Format the publication date nicely
    var formattedPublicationDate: String {
        book?.formattedPublicationDate ?? "Unknown publication date"
    }
    
    /// Star rating display
    var ratingStars: String {
        book?.ratingText ?? "Not rated"
    }
    
    /// Check if the book is currently being read
    var isInProgress: Bool {
        book?.isInProgress ?? false
    }
    
    /// Check if the book has been completed
    var isCompleted: Bool {
        book?.isRead ?? false
    }
}
