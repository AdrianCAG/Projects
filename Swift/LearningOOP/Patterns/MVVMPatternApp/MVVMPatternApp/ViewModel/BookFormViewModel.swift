//
//  BookFormViewModel.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import Foundation
import Combine

/// ViewModel for managing the book form (add/edit)
class BookFormViewModel: ObservableObject {
    // Form input properties
    @Published var title: String = ""
    @Published var author: String = ""
    @Published var genre: BookGenre = .fiction
    @Published var status: ReadingStatus = .unread
    @Published var format: BookFormat = .paperback
    @Published var publicationDate: Date? = nil
    @Published var rating: Int? = nil
    @Published var notes: String = ""
    @Published var coverImageName: String? = nil
    
    // Validation and state properties
    @Published var isSaving: Bool = false
    @Published var formErrors: [String] = []
    @Published var isEditMode: Bool = false
    
    // The book being edited, if in edit mode
    private var editingBookId: UUID?
    
    // Repository reference
    private let repository: BookRepositoryProtocol
    
    // MARK: - Initialization
    
    init(book: Book? = nil, repository: BookRepositoryProtocol = BookRepository.shared) {
        self.repository = repository
        
        // If a book is provided, we're in edit mode
        if let book = book {
            setupForEditing(book)
        }
    }
    
    /// Sets up the form for editing an existing book
    private func setupForEditing(_ book: Book) {
        title = book.title
        author = book.author
        genre = book.genre
        status = book.status
        format = book.format
        publicationDate = book.publicationDate
        rating = book.rating
        notes = book.notes
        coverImageName = book.coverImageName
        
        editingBookId = book.id
        isEditMode = true
    }
    
    // MARK: - Form Actions
    
    /// Validates the form and returns true if valid
    func validateForm() -> Bool {
        formErrors = []
        
        // Title is required
        if title.isEmpty {
            formErrors.append("Title is required")
        }
        
        // Author is required
        if author.isEmpty {
            formErrors.append("Author is required")
        }
        
        // Rating must be between 1-5 if provided
        if let rating = rating, (rating < 1 || rating > 5) {
            formErrors.append("Rating must be between 1 and 5 stars")
        }
        
        return formErrors.isEmpty
    }
    
    /// Saves the book (create new or update existing)
    func saveBook() -> Bool {
        // Validate form first
        if !validateForm() {
            return false
        }
        
        isSaving = true
        
        // Determine if we're creating or updating
        if isEditMode, let id = editingBookId {
            // Update existing book
            let updatedBook = Book(
                id: id,
                title: title,
                author: author,
                genre: genre,
                status: status,
                format: format,
                publicationDate: publicationDate,
                rating: rating,
                notes: notes,
                coverImageName: coverImageName
            )
            
            repository.updateBook(updatedBook)
        } else {
            // Create new book
            let newBook = Book(
                title: title,
                author: author,
                genre: genre,
                status: status,
                format: format,
                publicationDate: publicationDate,
                rating: rating,
                notes: notes,
                coverImageName: coverImageName
            )
            
            repository.addBook(newBook)
        }
        
        isSaving = false
        return true
    }
    
    /// Resets the form to default values
    func resetForm() {
        title = ""
        author = ""
        genre = .fiction
        status = .unread
        format = .paperback
        publicationDate = nil
        rating = nil
        notes = ""
        coverImageName = nil
        formErrors = []
    }
    
    // MARK: - Helper Methods
    
    /// Updates the rating value
    func setRating(_ value: Int) {
        if (1...5).contains(value) {
            rating = value
        }
    }
    
    /// Clears the rating
    func clearRating() {
        rating = nil
    }
    
    // MARK: - Computed Properties
    
    /// The title for the form based on mode
    var formTitle: String {
        return isEditMode ? "Edit Book" : "Add New Book"
    }
    
    /// The text for the save button
    var saveButtonText: String {
        return isEditMode ? "Update" : "Add to Library"
    }
    
    /// Check if the form has any input
    var hasInput: Bool {
        return !title.isEmpty || !author.isEmpty || !notes.isEmpty || rating != nil
    }
}
