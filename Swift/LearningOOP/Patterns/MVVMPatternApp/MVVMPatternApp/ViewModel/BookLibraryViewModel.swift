//
//  BookLibraryViewModel.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import Foundation
import Combine

/// SortOption represents different ways to sort books
enum SortOption: String, CaseIterable, Identifiable {
    case title = "Title"
    case author = "Author"
    case dateAdded = "Date Added"
    case publicationDate = "Publication Date"
    
    var id: String { self.rawValue }
}

/// ViewModel for managing the book library view
class BookLibraryViewModel: ObservableObject {
    // Published properties will automatically notify the view of changes
    @Published var books: [Book] = []
    @Published var filteredBooks: [Book] = []
    
    // Filter states
    @Published var selectedGenre: BookGenre?
    @Published var selectedStatus: ReadingStatus?
    @Published var selectedFormat: BookFormat?
    @Published var searchQuery: String = ""
    
    // Sort state
    @Published var sortOption: SortOption = .title
    @Published var sortAscending: Bool = true
    
    // Statistics
    @Published var genreCounts: [BookGenre: Int] = [:]
    @Published var statusCounts: [ReadingStatus: Int] = [:]
    
    // Repository reference
    private let repository: BookRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repository: BookRepositoryProtocol = BookRepository.shared) {
        self.repository = repository
        loadBooks()
    }
    
    // MARK: - Data Loading
    
    /// Loads books from the repository and updates all related properties
    func loadBooks() {
        books = repository.getBooks()
        updateFilteredBooks()
        updateStatistics()
    }
    
    // MARK: - Filtering and Sorting
    
    /// Updates the filtered books based on current filter settings
    func updateFilteredBooks() {
        // Start with all books
        var result = books
        
        // Apply genre filter if selected
        if let genre = selectedGenre {
            result = result.filter { $0.genre == genre }
        }
        
        // Apply status filter if selected
        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }
        
        // Apply format filter if selected
        if let format = selectedFormat {
            result = result.filter { $0.format == format }
        }
        
        // Apply search query if not empty
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.author.lowercased().contains(query)
            }
        }
        
        // Apply sorting
        result = sortBooks(result)
        
        // Update the filtered books
        filteredBooks = result
    }
    
    /// Sorts books based on the current sort option and direction
    private func sortBooks(_ books: [Book]) -> [Book] {
        switch sortOption {
        case .title:
            return books.sorted { sortAscending ? $0.title < $1.title : $0.title > $1.title }
            
        case .author:
            return books.sorted { sortAscending ? $0.author < $1.author : $0.author > $1.author }
            
        case .dateAdded:
            return books.sorted { sortAscending ? $0.dateAdded < $1.dateAdded : $0.dateAdded > $1.dateAdded }
            
        case .publicationDate:
            return books.sorted { book1, book2 in
                // Handle nil publication dates
                guard let date1 = book1.publicationDate else { return !sortAscending }
                guard let date2 = book2.publicationDate else { return sortAscending }
                return sortAscending ? date1 < date2 : date1 > date2
            }
        }
    }
    
    // MARK: - Filter Actions
    
    /// Sets the genre filter
    func setGenreFilter(_ genre: BookGenre?) {
        selectedGenre = genre
        updateFilteredBooks()
    }
    
    /// Sets the status filter
    func setStatusFilter(_ status: ReadingStatus?) {
        selectedStatus = status
        updateFilteredBooks()
    }
    
    /// Sets the format filter
    func setFormatFilter(_ format: BookFormat?) {
        selectedFormat = format
        updateFilteredBooks()
    }
    
    /// Updates the search query
    func setSearchQuery(_ query: String) {
        searchQuery = query
        updateFilteredBooks()
    }
    
    /// Clears all filters
    func clearFilters() {
        selectedGenre = nil
        selectedStatus = nil
        selectedFormat = nil
        searchQuery = ""
        updateFilteredBooks()
    }
    
    // MARK: - Sort Actions
    
    /// Sets the sort option
    func setSortOption(_ option: SortOption) {
        // If selecting the same option, toggle direction instead
        if sortOption == option {
            sortAscending.toggle()
        } else {
            sortOption = option
            sortAscending = true
        }
        updateFilteredBooks()
    }
    
    // MARK: - CRUD Operations
    
    /// Adds a new book
    func addBook(_ book: Book) {
        repository.addBook(book)
        loadBooks()
    }
    
    /// Updates an existing book
    func updateBook(_ book: Book) {
        repository.updateBook(book)
        loadBooks()
    }
    
    /// Deletes a book by ID
    func deleteBook(withId id: UUID) {
        repository.deleteBook(withId: id)
        loadBooks()
    }
    
    // MARK: - Statistics
    
    /// Updates the counts for genres and statuses
    private func updateStatistics() {
        // Reset counters
        var newGenreCounts: [BookGenre: Int] = [:]
        var newStatusCounts: [ReadingStatus: Int] = [:]
        
        // Count each genre
        for genre in BookGenre.allCases {
            newGenreCounts[genre] = books.filter { $0.genre == genre }.count
        }
        
        // Count each status
        for status in ReadingStatus.allCases {
            newStatusCounts[status] = books.filter { $0.status == status }.count
        }
        
        // Update published properties
        genreCounts = newGenreCounts
        statusCounts = newStatusCounts
    }
    
    // MARK: - Computed Properties
    
    /// Total number of books
    var totalBooks: Int {
        return books.count
    }
    
    /// Number of books currently being read
    var inProgressCount: Int {
        return books.filter { $0.status == .inProgress }.count
    }
    
    /// Number of completed books
    var completedCount: Int {
        return books.filter { $0.status == .completed }.count
    }
    
    /// Number of books filtered out by current filters
    var filteredOutCount: Int {
        return books.count - filteredBooks.count
    }
}
