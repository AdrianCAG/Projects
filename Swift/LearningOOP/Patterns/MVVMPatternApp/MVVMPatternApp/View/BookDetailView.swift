//
//  BookDetailView.swift
//  MVVMPatternApp
//
//  Created by Adrian on 5/13/25.
//

import SwiftUI

struct BookDetailView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: BookDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingNotesEditor = false
    @State private var editingNotes = ""
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Show loading state or error if present
                if viewModel.isLoading {
                    ProgressView("Loading book details...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let book = viewModel.book {
                    // Book cover section
                    BookCoverView(book: book)
                        .frame(height: 200)
                        .padding(.horizontal)
                    
                    // Book title and author
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("by \(book.author)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Book details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(label: "Genre", value: book.genre.rawValue, iconName: book.genre.iconName)
                        DetailRow(label: "Format", value: book.format.rawValue, iconName: book.format.iconName)
                        DetailRow(label: "Reading Status", value: viewModel.readingStatusText, iconName: viewModel.readingStatusIcon)
                        
                        if let publishDate = book.publicationDate {
                            DetailRow(label: "Publication Date", value: book.formattedPublicationDate, iconName: "calendar")
                        }
                        
                        DetailRow(label: "Rating", value: viewModel.ratingStars, iconName: "star.fill")
                    }
                    .padding(.horizontal)
                    
                    // Reading status actions
                    HStack(spacing: 12) {
                        StatusButton(title: "Not Started", iconName: "book.closed.fill", isActive: book.status == .unread) {
                            viewModel.updateReadingStatus(.unread)
                        }
                        
                        StatusButton(title: "Reading", iconName: "book.fill", isActive: viewModel.isInProgress) {
                            viewModel.updateReadingStatus(.inProgress)
                        }
                        
                        StatusButton(title: "Finished", iconName: "checkmark.circle.fill", isActive: viewModel.isCompleted) {
                            viewModel.updateReadingStatus(.completed)
                        }
                        
                        StatusButton(title: "Abandoned", iconName: "xmark.circle.fill", isActive: book.status == .abandoned) {
                            viewModel.updateReadingStatus(.abandoned)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Rating section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Rating")
                            .font(.headline)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: (book.rating ?? 0) >= star ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                                    .onTapGesture {
                                        viewModel.updateRating(star)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Notes section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Notes")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                editingNotes = book.notes
                                showingNotesEditor = true
                            }) {
                                Text("Edit")
                                    .font(.subheadline)
                            }
                        }
                        
                        if book.notes.isEmpty {
                            Text("No notes yet. Tap Edit to add your thoughts about this book.")
                                .foregroundColor(.secondary)
                                .italic()
                                .padding(.top, 4)
                        } else {
                            Text(book.notes)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Date added
                    Text("Added to library on \(book.formattedDateAdded)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitle("Book Details", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Image(systemName: "pencil")
                    }
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let book = viewModel.book {
                NavigationView {
                    BookFormView(viewModel: BookFormViewModel(book: book))
                        .navigationTitle("Edit Book")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Cancel") {
                                    showingEditSheet = false
                                }
                            }
                        }
                }
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Book"),
                message: Text("Are you sure you want to delete this book from your library? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    if viewModel.deleteBook() {
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingNotesEditor) {
            NavigationView {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $editingNotes)
                        .padding()
                    
                    if editingNotes.isEmpty {
                        Text("Write your thoughts about this book...")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }
                }
                .navigationTitle("Edit Notes")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            viewModel.updateNotes(editingNotes)
                            showingNotesEditor = false
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingNotesEditor = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct BookCoverView: View {
    let book: Book
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(colorForGenre(book.genre))
            
            VStack(spacing: 16) {
                Image(systemName: book.genre.iconName)
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    Text(book.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func colorForGenre(_ genre: BookGenre) -> Color {
        switch genre {
        case .fiction: return Color.blue
        case .nonFiction: return Color.orange
        case .fantasy: return Color.purple
        case .sciFi: return Color.green
        case .mystery: return Color.red
        case .thriller: return Color.pink
        case .biography: return Color.yellow
        case .history: return Color.gray
        case .selfHelp: return Color.teal
        case .other: return Color.indigo
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

struct StatusButton: View {
    let title: String
    let iconName: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconName)
                    .font(.body)
                
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isActive ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(isActive ? .blue : .primary)
            .cornerRadius(8)
        }
    }
}

// MARK: - Preview

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookDetailView(viewModel: {
                let vm = BookDetailViewModel()
                vm.book = Book.sampleBooks[0]
                return vm
            }())
        }
    }
}
