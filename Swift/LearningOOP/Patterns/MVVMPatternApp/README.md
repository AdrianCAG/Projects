# MVVM Pattern App

A Swift iOS application that demonstrates the Model-View-ViewModel (MVVM) architectural pattern through a personal book collection management system.

## Overview

This application is an intuitive book collection manager that allows users to catalog, organize, and track their personal library. Users can add books, categorize them by genre, mark reading status, and maintain notes about each book. It serves as a practical demonstration of the MVVM architectural pattern, illustrating how to effectively separate concerns in an iOS application.

## Design Pattern: Model-View-ViewModel (MVVM)

The Model-View-ViewModel (MVVM) pattern is a structural design pattern that separates objects into three distinct groups:
- Models hold application data
- Views display the user interface
- ViewModels transform data from the Model into information the View can display

Unlike MVC, MVVM introduces the ViewModel as an abstraction of the View, which exposes public properties and commands that the View can bind to.

### Key Components in This Implementation

1. **Model**: Represents the application's data and business logic
   - `Book`: Core data model representing a book with properties and computed values
   - `BookGenre`, `ReadingStatus`, `BookFormat`: Enums that define book attributes
   
2. **View**: Represents the UI elements that display data to the user
   - `BookLibraryView`: Displays the collection of books
   - `BookDetailView`: Shows detailed information about a specific book
   - `BookFormView`: Allows adding and editing books
   - Various supporting views like `BookCardView`, `GenreFilterView`, etc.
   
3. **ViewModel**: Acts as a mediator between Model and View
   - `BookLibraryViewModel`: Provides data and commands for the library view
   - `BookDetailViewModel`: Provides data and commands for book detail view
   - `BookFormViewModel`: Handles book creation and editing logic

## Project Structure

```
MVVMPatternApp/
├── Model/
│   ├── Book.swift                 # Core data model
│   └── BookRepository.swift       # Data access and persistence
├── View/
│   ├── BookLibraryView.swift      # Main book collection view
│   ├── BookDetailView.swift       # Book details
│   ├── BookFormView.swift         # Add/edit book form
│   ├── BookCardView.swift         # Individual book card
│   ├── GenreFilterView.swift      # Genre filtering options
│   └── EmptyLibraryView.swift     # Empty state UI
├── ViewModel/
│   ├── BookLibraryViewModel.swift  # Logic for library view
│   ├── BookDetailViewModel.swift   # Logic for book details
│   └── BookFormViewModel.swift     # Logic for book form
├── ContentView.swift               # Main app view
└── MVVMPatternAppApp.swift         # App entry point
```

## Features

- Add, view, update, and remove books from your collection
- Categorize books by genre (Fiction, Non-Fiction, Fantasy, Sci-Fi, etc.)
- Track reading status (Unread, In Progress, Completed, Abandoned)
- Record book formats (Hardcover, Paperback, E-Book, Audiobook)
- Add publication dates, authors, and personal notes
- Filter books by genre, reading status, and format
- Sort books by various criteria (title, author, date added, etc.)
- View reading statistics and collection insights

## How the MVVM Pattern is Applied

### Model Layer
- The `Book` struct represents the core data model with properties like title, author, genre, reading status, etc.
- Supporting enums (`BookGenre`, `ReadingStatus`, `BookFormat`) define the possible values for book attributes
- The `BookRepository` handles data access operations and persistence

### View Layer
- SwiftUI views that display the UI and capture user interactions
- Views don't contain business logic or directly manipulate data
- Views observe their respective ViewModels using SwiftUI's `@ObservedObject` property wrapper
- The View sends user actions to the ViewModel and renders the UI based on the ViewModel's state

### ViewModel Layer
- ViewModels act as an abstraction of the View and a mediator between Model and View
- Each ViewModel:
  - Exposes the data needed by the View in a format the View can easily consume
  - Provides methods that handle user interactions from the View
  - Contains presentation logic but not UI-specific code
  - Conforms to `ObservableObject` to notify Views of changes
  - Interacts with the Model to retrieve and update data

## Benefits of the MVVM Pattern

1. **Testability**: ViewModels are independent of UI frameworks, making them easier to test
2. **Maintainability**: Separation of concerns makes the code easier to understand and modify
3. **Reusability**: ViewModels can be reused across different Views
4. **Scalability**: Clear separation makes it easier to add new features or modify existing ones
5. **Two-Way Data Binding**: ViewModels expose properties that Views can bind to for automatic updates

## Comparison to MVC Pattern

| Aspect | MVC | MVVM |
|--------|-----|------|
| Components | Model, View, Controller | Model, View, ViewModel |
| Responsibility Division | Controller mediates between Model and View | ViewModel transforms Model data for View; View is responsible for user interactions |
| Data Binding | Manual, Controller-managed | Declarative, often using observable properties |
| Testability | Controllers often tightly coupled to Views | ViewModels completely independent of UI framework |
| Code-Behind | Controllers handle UI events | ViewModels expose commands/properties that Views bind to |
| UI Logic | Often in both Controller and View | Mostly in ViewModel, View contains minimal code |

## Running the Application

To run the application:

1. Open the `MVVMPatternApp.xcodeproj` file in Xcode
2. Select a simulator or connected device
3. Press the Run button (⌘+R)

## Usage Example

The application allows you to:

1. Browse your book collection with filtering and sorting options
2. Add new books with detailed information
3. Edit existing book entries to update reading status or notes
4. Remove books from your collection
5. View reading statistics and insights about your library

## Implementation Details

- Built with SwiftUI for the user interface
- Uses Combine framework for reactive programming
- Implements UserDefaults for data persistence
- Follows SOLID principles for clean architecture
- Demonstrates proper data binding between View and ViewModel
